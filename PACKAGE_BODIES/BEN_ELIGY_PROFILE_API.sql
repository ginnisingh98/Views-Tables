--------------------------------------------------------
--  DDL for Package Body BEN_ELIGY_PROFILE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGY_PROFILE_API" as
/* $Header: beelpapi.pkb 120.1 2005/06/07 01:03:05 swjain noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIGY_PROFILE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIGY_PROFILE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIGY_PROFILE
  (p_validate                       in  boolean   default false
  ,p_eligy_prfl_id                  out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_stat_cd                        in  varchar2  default null
  ,p_asmt_to_use_cd                 in  varchar2  default null
  ,p_elig_enrld_plip_flag           in  varchar2  default 'N'
  ,p_elig_cbr_quald_bnf_flag        in  varchar2  default 'N'
  ,p_elig_enrld_ptip_flag           in  varchar2  default 'N'
  ,p_elig_dpnt_cvrd_plip_flag       in  varchar2  default 'N'
  ,p_elig_dpnt_cvrd_ptip_flag       in  varchar2  default 'N'
  ,p_elig_dpnt_cvrd_pgm_flag        in  varchar2  default 'N'
  ,p_elig_job_flag                  in  varchar2  default 'N'
  ,p_elig_hrly_slrd_flag            in  varchar2  default 'N'
  ,p_elig_pstl_cd_flag              in  varchar2  default 'N'
  ,p_elig_lbr_mmbr_flag             in  varchar2  default 'N'
  ,p_elig_lgl_enty_flag             in  varchar2  default 'N'
  ,p_elig_benfts_grp_flag           in  varchar2  default 'N'
  ,p_elig_wk_loc_flag               in  varchar2  default 'N'
  ,p_elig_brgng_unit_flag           in  varchar2  default 'N'
  ,p_elig_age_flag                  in  varchar2  default 'N'
  ,p_elig_los_flag                  in  varchar2  default 'N'
  ,p_elig_per_typ_flag              in  varchar2  default 'N'
  ,p_elig_fl_tm_pt_tm_flag          in  varchar2  default 'N'
  ,p_elig_ee_stat_flag              in  varchar2  default 'N'
  ,p_elig_grd_flag                  in  varchar2  default 'N'
  ,p_elig_pct_fl_tm_flag            in  varchar2  default 'N'
  ,p_elig_asnt_set_flag             in  varchar2  default 'N'
  ,p_elig_hrs_wkd_flag              in  varchar2  default 'N'
  ,p_elig_comp_lvl_flag             in  varchar2  default 'N'
  ,p_elig_org_unit_flag             in  varchar2  default 'N'
  ,p_elig_loa_rsn_flag              in  varchar2  default 'N'
  ,p_elig_pyrl_flag                 in  varchar2  default 'N'
  ,p_elig_schedd_hrs_flag           in  varchar2  default 'N'
  ,p_elig_py_bss_flag               in  varchar2  default 'N'
  ,p_eligy_prfl_rl_flag             in  varchar2  default 'N'
  ,p_elig_cmbn_age_los_flag         in  varchar2  default 'N'
  ,p_cntng_prtn_elig_prfl_flag      in  varchar2  default 'N'
  ,p_elig_prtt_pl_flag              in  varchar2  default 'N'
  ,p_elig_ppl_grp_flag              in  varchar2  default 'N'
  ,p_elig_svc_area_flag             in  varchar2  default 'N'
  ,p_elig_ptip_prte_flag            in  varchar2  default 'N'
  ,p_elig_no_othr_cvg_flag          in  varchar2  default 'N'
  ,p_elig_enrld_pl_flag             in  varchar2  default 'N'
  ,p_elig_enrld_oipl_flag           in  varchar2  default 'N'
  ,p_elig_enrld_pgm_flag            in  varchar2  default 'N'
  ,p_elig_dpnt_cvrd_pl_flag         in  varchar2  default 'N'
  ,p_elig_lvg_rsn_flag              in  varchar2  default 'N'
  ,p_elig_optd_mdcr_flag            in  varchar2  default 'N'
  ,p_elig_tbco_use_flag             in  varchar2  default 'N'
  ,p_elig_dpnt_othr_ptip_flag       in  varchar2  default 'N'
  ,p_business_group_id              in  number    default null
  ,p_elp_attribute_category         in  varchar2  default null
  ,p_elp_attribute1                 in  varchar2  default null
  ,p_elp_attribute2                 in  varchar2  default null
  ,p_elp_attribute3                 in  varchar2  default null
  ,p_elp_attribute4                 in  varchar2  default null
  ,p_elp_attribute5                 in  varchar2  default null
  ,p_elp_attribute6                 in  varchar2  default null
  ,p_elp_attribute7                 in  varchar2  default null
  ,p_elp_attribute8                 in  varchar2  default null
  ,p_elp_attribute9                 in  varchar2  default null
  ,p_elp_attribute10                in  varchar2  default null
  ,p_elp_attribute11                in  varchar2  default null
  ,p_elp_attribute12                in  varchar2  default null
  ,p_elp_attribute13                in  varchar2  default null
  ,p_elp_attribute14                in  varchar2  default null
  ,p_elp_attribute15                in  varchar2  default null
  ,p_elp_attribute16                in  varchar2  default null
  ,p_elp_attribute17                in  varchar2  default null
  ,p_elp_attribute18                in  varchar2  default null
  ,p_elp_attribute19                in  varchar2  default null
  ,p_elp_attribute20                in  varchar2  default null
  ,p_elp_attribute21                in  varchar2  default null
  ,p_elp_attribute22                in  varchar2  default null
  ,p_elp_attribute23                in  varchar2  default null
  ,p_elp_attribute24                in  varchar2  default null
  ,p_elp_attribute25                in  varchar2  default null
  ,p_elp_attribute26                in  varchar2  default null
  ,p_elp_attribute27                in  varchar2  default null
  ,p_elp_attribute28                in  varchar2  default null
  ,p_elp_attribute29                in  varchar2  default null
  ,p_elp_attribute30                in  varchar2  default null
  ,p_elig_mrtl_sts_flag             in  varchar2  default 'N'
  ,p_elig_gndr_flag                 in  varchar2  default 'N'
  ,p_elig_dsblty_ctg_flag           in  varchar2  default 'N'
  ,p_elig_dsblty_rsn_flag           in  varchar2  default 'N'
  ,p_elig_dsblty_dgr_flag           in  varchar2  default 'N'
  ,p_elig_suppl_role_flag           in  varchar2  default 'N'
  ,p_elig_qual_titl_flag            in  varchar2  default 'N'
  ,p_elig_pstn_flag                 in  varchar2  default 'N'
  ,p_elig_prbtn_perd_flag           in  varchar2  default 'N'
  ,p_elig_sp_clng_prg_pt_flag       in  varchar2  default 'N'
  ,p_bnft_cagr_prtn_cd              in  varchar2  default null
  ,p_elig_dsbld_flag                in  varchar2  default 'N'
  ,p_elig_ttl_cvg_vol_flag          in  varchar2  default 'N'
  ,p_elig_ttl_prtt_flag             in  varchar2  default 'N'
  ,p_elig_comptncy_flag             in  varchar2  default 'N'
  ,p_elig_hlth_cvg_flag		    in  varchar2  default 'N'
  ,p_elig_anthr_pl_flag		    in  varchar2  default 'N'
  ,p_elig_qua_in_gr_flag	    in  varchar2  default 'N'
  ,p_elig_perf_rtng_flag	    in  varchar2  default 'N'
  ,p_elig_crit_values_flag          in  varchar2  default 'N'  /* RBC */
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_eligy_prfl_id ben_eligy_prfl_f.eligy_prfl_id%TYPE;
  l_effective_start_date ben_eligy_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_eligy_prfl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIGY_PROFILE';
  l_object_version_number ben_eligy_prfl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIGY_PROFILE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIGY_PROFILE
    --
    ben_ELIGY_PROFILE_bk1.create_ELIGY_PROFILE_b
      (p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_stat_cd                        =>  p_stat_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_elig_enrld_plip_flag           =>  p_elig_enrld_plip_flag
      ,p_elig_cbr_quald_bnf_flag        =>  p_elig_cbr_quald_bnf_flag
      ,p_elig_enrld_ptip_flag           =>  p_elig_enrld_ptip_flag
      ,p_elig_dpnt_cvrd_plip_flag       =>  p_elig_dpnt_cvrd_plip_flag
      ,p_elig_dpnt_cvrd_ptip_flag       =>  p_elig_dpnt_cvrd_ptip_flag
      ,p_elig_dpnt_cvrd_pgm_flag        =>  p_elig_dpnt_cvrd_pgm_flag
      ,p_elig_job_flag                  =>  p_elig_job_flag
      ,p_elig_hrly_slrd_flag            =>  p_elig_hrly_slrd_flag
      ,p_elig_pstl_cd_flag              =>  p_elig_pstl_cd_flag
      ,p_elig_lbr_mmbr_flag             =>  p_elig_lbr_mmbr_flag
      ,p_elig_lgl_enty_flag             =>  p_elig_lgl_enty_flag
      ,p_elig_benfts_grp_flag           =>  p_elig_benfts_grp_flag
      ,p_elig_wk_loc_flag               =>  p_elig_wk_loc_flag
      ,p_elig_brgng_unit_flag           =>  p_elig_brgng_unit_flag
      ,p_elig_age_flag                  =>  p_elig_age_flag
      ,p_elig_los_flag                  =>  p_elig_los_flag
      ,p_elig_per_typ_flag              =>  p_elig_per_typ_flag
      ,p_elig_fl_tm_pt_tm_flag          =>  p_elig_fl_tm_pt_tm_flag
      ,p_elig_ee_stat_flag              =>  p_elig_ee_stat_flag
      ,p_elig_grd_flag                  =>  p_elig_grd_flag
      ,p_elig_pct_fl_tm_flag            =>  p_elig_pct_fl_tm_flag
      ,p_elig_asnt_set_flag             =>  p_elig_asnt_set_flag
      ,p_elig_hrs_wkd_flag              =>  p_elig_hrs_wkd_flag
      ,p_elig_comp_lvl_flag             =>  p_elig_comp_lvl_flag
      ,p_elig_org_unit_flag             =>  p_elig_org_unit_flag
      ,p_elig_loa_rsn_flag              =>  p_elig_loa_rsn_flag
      ,p_elig_pyrl_flag                 =>  p_elig_pyrl_flag
      ,p_elig_schedd_hrs_flag           =>  p_elig_schedd_hrs_flag
      ,p_elig_py_bss_flag               =>  p_elig_py_bss_flag
      ,p_eligy_prfl_rl_flag             =>  p_eligy_prfl_rl_flag
      ,p_elig_cmbn_age_los_flag         =>  p_elig_cmbn_age_los_flag
      ,p_cntng_prtn_elig_prfl_flag      =>  p_cntng_prtn_elig_prfl_flag
      ,p_elig_prtt_pl_flag              =>  p_elig_prtt_pl_flag
      ,p_elig_ppl_grp_flag              =>  p_elig_ppl_grp_flag
      ,p_elig_svc_area_flag             =>  p_elig_svc_area_flag
      ,p_elig_ptip_prte_flag            =>  p_elig_ptip_prte_flag
      ,p_elig_no_othr_cvg_flag          =>  p_elig_no_othr_cvg_flag
      ,p_elig_enrld_pl_flag             =>  p_elig_enrld_pl_flag
      ,p_elig_enrld_oipl_flag           =>  p_elig_enrld_oipl_flag
      ,p_elig_enrld_pgm_flag            =>  p_elig_enrld_pgm_flag
      ,p_elig_dpnt_cvrd_pl_flag         =>  p_elig_dpnt_cvrd_pl_flag
      ,p_elig_lvg_rsn_flag              =>  p_elig_lvg_rsn_flag
      ,p_elig_optd_mdcr_flag            =>  p_elig_optd_mdcr_flag
      ,p_elig_tbco_use_flag             =>  p_elig_tbco_use_flag
      ,p_elig_dpnt_othr_ptip_flag       =>  p_elig_dpnt_othr_ptip_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_elp_attribute_category         =>  p_elp_attribute_category
      ,p_elp_attribute1                 =>  p_elp_attribute1
      ,p_elp_attribute2                 =>  p_elp_attribute2
      ,p_elp_attribute3                 =>  p_elp_attribute3
      ,p_elp_attribute4                 =>  p_elp_attribute4
      ,p_elp_attribute5                 =>  p_elp_attribute5
      ,p_elp_attribute6                 =>  p_elp_attribute6
      ,p_elp_attribute7                 =>  p_elp_attribute7
      ,p_elp_attribute8                 =>  p_elp_attribute8
      ,p_elp_attribute9                 =>  p_elp_attribute9
      ,p_elp_attribute10                =>  p_elp_attribute10
      ,p_elp_attribute11                =>  p_elp_attribute11
      ,p_elp_attribute12                =>  p_elp_attribute12
      ,p_elp_attribute13                =>  p_elp_attribute13
      ,p_elp_attribute14                =>  p_elp_attribute14
      ,p_elp_attribute15                =>  p_elp_attribute15
      ,p_elp_attribute16                =>  p_elp_attribute16
      ,p_elp_attribute17                =>  p_elp_attribute17
      ,p_elp_attribute18                =>  p_elp_attribute18
      ,p_elp_attribute19                =>  p_elp_attribute19
      ,p_elp_attribute20                =>  p_elp_attribute20
      ,p_elp_attribute21                =>  p_elp_attribute21
      ,p_elp_attribute22                =>  p_elp_attribute22
      ,p_elp_attribute23                =>  p_elp_attribute23
      ,p_elp_attribute24                =>  p_elp_attribute24
      ,p_elp_attribute25                =>  p_elp_attribute25
      ,p_elp_attribute26                =>  p_elp_attribute26
      ,p_elp_attribute27                =>  p_elp_attribute27
      ,p_elp_attribute28                =>  p_elp_attribute28
      ,p_elp_attribute29                =>  p_elp_attribute29
      ,p_elp_attribute30                =>  p_elp_attribute30
      ,p_elig_mrtl_sts_flag             =>  p_elig_mrtl_sts_flag
      ,p_elig_gndr_flag                 =>  p_elig_gndr_flag
      ,p_elig_dsblty_ctg_flag           =>  p_elig_dsblty_ctg_flag
      ,p_elig_dsblty_rsn_flag           =>  p_elig_dsblty_rsn_flag
      ,p_elig_dsblty_dgr_flag           =>  p_elig_dsblty_dgr_flag
      ,p_elig_suppl_role_flag           =>  p_elig_suppl_role_flag
      ,p_elig_qual_titl_flag            =>  p_elig_qual_titl_flag
      ,p_elig_pstn_flag                 =>  p_elig_pstn_flag
      ,p_elig_prbtn_perd_flag           =>  p_elig_prbtn_perd_flag
      ,p_elig_sp_clng_prg_pt_flag       =>  p_elig_sp_clng_prg_pt_flag
      ,p_bnft_cagr_prtn_cd              =>  p_bnft_cagr_prtn_cd
      ,p_elig_dsbld_flag        	=>  p_elig_dsbld_flag
      ,p_elig_ttl_cvg_vol_flag  	=>  p_elig_ttl_cvg_vol_flag
      ,p_elig_ttl_prtt_flag     	=>  p_elig_ttl_prtt_flag
      ,p_elig_comptncy_flag     	=>  p_elig_comptncy_flag
      ,p_elig_hlth_cvg_flag		=>  p_elig_hlth_cvg_flag
      ,p_elig_anthr_pl_flag		=>  p_elig_anthr_pl_flag
      ,p_elig_qua_in_gr_flag		=>  p_elig_qua_in_gr_flag
      ,p_elig_perf_rtng_flag		=>  p_elig_perf_rtng_flag
      ,p_elig_crit_values_flag          =>  p_elig_crit_values_flag   /* RBC */
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIGY_PROFILE'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_ELIGY_PROFILE
    --
  end;
  --
  ben_elp_ins.ins
    (p_eligy_prfl_id                 => l_eligy_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_description                   => p_description
    ,p_stat_cd                       => p_stat_cd
    ,p_asmt_to_use_cd                => p_asmt_to_use_cd
    ,p_elig_enrld_plip_flag          => p_elig_enrld_plip_flag
    ,p_elig_cbr_quald_bnf_flag       => p_elig_cbr_quald_bnf_flag
    ,p_elig_enrld_ptip_flag          => p_elig_enrld_ptip_flag
    ,p_elig_dpnt_cvrd_plip_flag      => p_elig_dpnt_cvrd_plip_flag
    ,p_elig_dpnt_cvrd_ptip_flag      => p_elig_dpnt_cvrd_ptip_flag
    ,p_elig_dpnt_cvrd_pgm_flag       => p_elig_dpnt_cvrd_pgm_flag
    ,p_elig_job_flag                 => p_elig_job_flag
    ,p_elig_hrly_slrd_flag           => p_elig_hrly_slrd_flag
    ,p_elig_pstl_cd_flag             => p_elig_pstl_cd_flag
    ,p_elig_lbr_mmbr_flag            => p_elig_lbr_mmbr_flag
    ,p_elig_lgl_enty_flag            => p_elig_lgl_enty_flag
    ,p_elig_benfts_grp_flag          => p_elig_benfts_grp_flag
    ,p_elig_wk_loc_flag              => p_elig_wk_loc_flag
    ,p_elig_brgng_unit_flag          => p_elig_brgng_unit_flag
    ,p_elig_age_flag                 => p_elig_age_flag
    ,p_elig_los_flag                 => p_elig_los_flag
    ,p_elig_per_typ_flag             => p_elig_per_typ_flag
    ,p_elig_fl_tm_pt_tm_flag         => p_elig_fl_tm_pt_tm_flag
    ,p_elig_ee_stat_flag             => p_elig_ee_stat_flag
    ,p_elig_grd_flag                 => p_elig_grd_flag
    ,p_elig_pct_fl_tm_flag           => p_elig_pct_fl_tm_flag
    ,p_elig_asnt_set_flag            => p_elig_asnt_set_flag
    ,p_elig_hrs_wkd_flag             => p_elig_hrs_wkd_flag
    ,p_elig_comp_lvl_flag            => p_elig_comp_lvl_flag
    ,p_elig_org_unit_flag            => p_elig_org_unit_flag
    ,p_elig_loa_rsn_flag             => p_elig_loa_rsn_flag
    ,p_elig_pyrl_flag                => p_elig_pyrl_flag
    ,p_elig_schedd_hrs_flag          => p_elig_schedd_hrs_flag
    ,p_elig_py_bss_flag              => p_elig_py_bss_flag
    ,p_eligy_prfl_rl_flag            => p_eligy_prfl_rl_flag
    ,p_elig_cmbn_age_los_flag        => p_elig_cmbn_age_los_flag
    ,p_cntng_prtn_elig_prfl_flag     => p_cntng_prtn_elig_prfl_flag
    ,p_elig_prtt_pl_flag             => p_elig_prtt_pl_flag
    ,p_elig_ppl_grp_flag             => p_elig_ppl_grp_flag
    ,p_elig_svc_area_flag            => p_elig_svc_area_flag
    ,p_elig_ptip_prte_flag           => p_elig_ptip_prte_flag
    ,p_elig_no_othr_cvg_flag         => p_elig_no_othr_cvg_flag
    ,p_elig_enrld_pl_flag            => p_elig_enrld_pl_flag
    ,p_elig_enrld_oipl_flag          => p_elig_enrld_oipl_flag
    ,p_elig_enrld_pgm_flag           => p_elig_enrld_pgm_flag
    ,p_elig_dpnt_cvrd_pl_flag        => p_elig_dpnt_cvrd_pl_flag
    ,p_elig_lvg_rsn_flag             => p_elig_lvg_rsn_flag
    ,p_elig_optd_mdcr_flag           => p_elig_optd_mdcr_flag
    ,p_elig_tbco_use_flag            => p_elig_tbco_use_flag
    ,p_elig_dpnt_othr_ptip_flag      =>  p_elig_dpnt_othr_ptip_flag
    ,p_business_group_id             => p_business_group_id
    ,p_elp_attribute_category        => p_elp_attribute_category
    ,p_elp_attribute1                => p_elp_attribute1
    ,p_elp_attribute2                => p_elp_attribute2
    ,p_elp_attribute3                => p_elp_attribute3
    ,p_elp_attribute4                => p_elp_attribute4
    ,p_elp_attribute5                => p_elp_attribute5
    ,p_elp_attribute6                => p_elp_attribute6
    ,p_elp_attribute7                => p_elp_attribute7
    ,p_elp_attribute8                => p_elp_attribute8
    ,p_elp_attribute9                => p_elp_attribute9
    ,p_elp_attribute10               => p_elp_attribute10
    ,p_elp_attribute11               => p_elp_attribute11
    ,p_elp_attribute12               => p_elp_attribute12
    ,p_elp_attribute13               => p_elp_attribute13
    ,p_elp_attribute14               => p_elp_attribute14
    ,p_elp_attribute15               => p_elp_attribute15
    ,p_elp_attribute16               => p_elp_attribute16
    ,p_elp_attribute17               => p_elp_attribute17
    ,p_elp_attribute18               => p_elp_attribute18
    ,p_elp_attribute19               => p_elp_attribute19
    ,p_elp_attribute20               => p_elp_attribute20
    ,p_elp_attribute21               => p_elp_attribute21
    ,p_elp_attribute22               => p_elp_attribute22
    ,p_elp_attribute23               => p_elp_attribute23
    ,p_elp_attribute24               => p_elp_attribute24
    ,p_elp_attribute25               => p_elp_attribute25
    ,p_elp_attribute26               => p_elp_attribute26
    ,p_elp_attribute27               => p_elp_attribute27
    ,p_elp_attribute28               => p_elp_attribute28
    ,p_elp_attribute29               => p_elp_attribute29
    ,p_elp_attribute30               => p_elp_attribute30
    ,p_elig_mrtl_sts_flag            => p_elig_mrtl_sts_flag
    ,p_elig_gndr_flag                => p_elig_gndr_flag
    ,p_elig_dsblty_ctg_flag          => p_elig_dsblty_ctg_flag
    ,p_elig_dsblty_rsn_flag          => p_elig_dsblty_rsn_flag
    ,p_elig_dsblty_dgr_flag          => p_elig_dsblty_dgr_flag
    ,p_elig_suppl_role_flag          => p_elig_suppl_role_flag
    ,p_elig_qual_titl_flag           => p_elig_qual_titl_flag
    ,p_elig_pstn_flag                => p_elig_pstn_flag
    ,p_elig_prbtn_perd_flag          => p_elig_prbtn_perd_flag
    ,p_elig_sp_clng_prg_pt_flag      => p_elig_sp_clng_prg_pt_flag
    ,p_bnft_cagr_prtn_cd             => p_bnft_cagr_prtn_cd
    ,p_elig_dsbld_flag               => p_elig_dsbld_flag
    ,p_elig_ttl_cvg_vol_flag         => p_elig_ttl_cvg_vol_flag
    ,p_elig_ttl_prtt_flag            => p_elig_ttl_prtt_flag
    ,p_elig_comptncy_flag            => p_elig_comptncy_flag
    ,p_elig_hlth_cvg_flag	     => p_elig_hlth_cvg_flag
    ,p_elig_anthr_pl_flag	     => p_elig_anthr_pl_flag
    ,p_elig_qua_in_gr_flag	     => p_elig_qua_in_gr_flag
    ,p_elig_perf_rtng_flag	     => p_elig_perf_rtng_flag
    ,p_elig_crit_values_flag         => p_elig_crit_values_flag   /* RBC */
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIGY_PROFILE
    --
    ben_ELIGY_PROFILE_bk1.create_ELIGY_PROFILE_a
      (p_eligy_prfl_id                  =>  l_eligy_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_stat_cd                        =>  p_stat_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_elig_enrld_plip_flag           =>  p_elig_enrld_plip_flag
      ,p_elig_cbr_quald_bnf_flag        =>  p_elig_cbr_quald_bnf_flag
      ,p_elig_enrld_ptip_flag           =>  p_elig_enrld_ptip_flag
      ,p_elig_dpnt_cvrd_plip_flag       =>  p_elig_dpnt_cvrd_plip_flag
      ,p_elig_dpnt_cvrd_ptip_flag       =>  p_elig_dpnt_cvrd_ptip_flag
      ,p_elig_dpnt_cvrd_pgm_flag        =>  p_elig_dpnt_cvrd_pgm_flag
      ,p_elig_job_flag                  =>  p_elig_job_flag
      ,p_elig_hrly_slrd_flag            =>  p_elig_hrly_slrd_flag
      ,p_elig_pstl_cd_flag              =>  p_elig_pstl_cd_flag
      ,p_elig_lbr_mmbr_flag             =>  p_elig_lbr_mmbr_flag
      ,p_elig_lgl_enty_flag             =>  p_elig_lgl_enty_flag
      ,p_elig_benfts_grp_flag           =>  p_elig_benfts_grp_flag
      ,p_elig_wk_loc_flag               =>  p_elig_wk_loc_flag
      ,p_elig_brgng_unit_flag           =>  p_elig_brgng_unit_flag
      ,p_elig_age_flag                  =>  p_elig_age_flag
      ,p_elig_los_flag                  =>  p_elig_los_flag
      ,p_elig_per_typ_flag              =>  p_elig_per_typ_flag
      ,p_elig_fl_tm_pt_tm_flag          =>  p_elig_fl_tm_pt_tm_flag
      ,p_elig_ee_stat_flag              =>  p_elig_ee_stat_flag
      ,p_elig_grd_flag                  =>  p_elig_grd_flag
      ,p_elig_pct_fl_tm_flag            =>  p_elig_pct_fl_tm_flag
      ,p_elig_asnt_set_flag             =>  p_elig_asnt_set_flag
      ,p_elig_hrs_wkd_flag              =>  p_elig_hrs_wkd_flag
      ,p_elig_comp_lvl_flag             =>  p_elig_comp_lvl_flag
      ,p_elig_org_unit_flag             =>  p_elig_org_unit_flag
      ,p_elig_loa_rsn_flag              =>  p_elig_loa_rsn_flag
      ,p_elig_pyrl_flag                 =>  p_elig_pyrl_flag
      ,p_elig_schedd_hrs_flag           =>  p_elig_schedd_hrs_flag
      ,p_elig_py_bss_flag               =>  p_elig_py_bss_flag
      ,p_eligy_prfl_rl_flag             =>  p_eligy_prfl_rl_flag
      ,p_elig_cmbn_age_los_flag         =>  p_elig_cmbn_age_los_flag
      ,p_cntng_prtn_elig_prfl_flag      =>  p_cntng_prtn_elig_prfl_flag
      ,p_elig_prtt_pl_flag              =>  p_elig_prtt_pl_flag
      ,p_elig_ppl_grp_flag              =>  p_elig_ppl_grp_flag
      ,p_elig_svc_area_flag             =>  p_elig_svc_area_flag
      ,p_elig_ptip_prte_flag            =>  p_elig_ptip_prte_flag
      ,p_elig_no_othr_cvg_flag          =>  p_elig_no_othr_cvg_flag
      ,p_elig_enrld_pl_flag             =>  p_elig_enrld_pl_flag
      ,p_elig_enrld_oipl_flag           =>  p_elig_enrld_oipl_flag
      ,p_elig_enrld_pgm_flag            =>  p_elig_enrld_pgm_flag
      ,p_elig_dpnt_cvrd_pl_flag         =>  p_elig_dpnt_cvrd_pl_flag
      ,p_elig_lvg_rsn_flag              =>  p_elig_lvg_rsn_flag
      ,p_elig_optd_mdcr_flag            =>  p_elig_optd_mdcr_flag
      ,p_elig_tbco_use_flag             =>  p_elig_tbco_use_flag
      ,p_elig_dpnt_othr_ptip_flag       =>  p_elig_dpnt_othr_ptip_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_elp_attribute_category         =>  p_elp_attribute_category
      ,p_elp_attribute1                 =>  p_elp_attribute1
      ,p_elp_attribute2                 =>  p_elp_attribute2
      ,p_elp_attribute3                 =>  p_elp_attribute3
      ,p_elp_attribute4                 =>  p_elp_attribute4
      ,p_elp_attribute5                 =>  p_elp_attribute5
      ,p_elp_attribute6                 =>  p_elp_attribute6
      ,p_elp_attribute7                 =>  p_elp_attribute7
      ,p_elp_attribute8                 =>  p_elp_attribute8
      ,p_elp_attribute9                 =>  p_elp_attribute9
      ,p_elp_attribute10                =>  p_elp_attribute10
      ,p_elp_attribute11                =>  p_elp_attribute11
      ,p_elp_attribute12                =>  p_elp_attribute12
      ,p_elp_attribute13                =>  p_elp_attribute13
      ,p_elp_attribute14                =>  p_elp_attribute14
      ,p_elp_attribute15                =>  p_elp_attribute15
      ,p_elp_attribute16                =>  p_elp_attribute16
      ,p_elp_attribute17                =>  p_elp_attribute17
      ,p_elp_attribute18                =>  p_elp_attribute18
      ,p_elp_attribute19                =>  p_elp_attribute19
      ,p_elp_attribute20                =>  p_elp_attribute20
      ,p_elp_attribute21                =>  p_elp_attribute21
      ,p_elp_attribute22                =>  p_elp_attribute22
      ,p_elp_attribute23                =>  p_elp_attribute23
      ,p_elp_attribute24                =>  p_elp_attribute24
      ,p_elp_attribute25                =>  p_elp_attribute25
      ,p_elp_attribute26                =>  p_elp_attribute26
      ,p_elp_attribute27                =>  p_elp_attribute27
      ,p_elp_attribute28                =>  p_elp_attribute28
      ,p_elp_attribute29                =>  p_elp_attribute29
      ,p_elp_attribute30                =>  p_elp_attribute30
      ,p_elig_mrtl_sts_flag             =>  p_elig_mrtl_sts_flag
      ,p_elig_gndr_flag                 =>  p_elig_gndr_flag
      ,p_elig_dsblty_ctg_flag           =>  p_elig_dsblty_ctg_flag
      ,p_elig_dsblty_rsn_flag           =>  p_elig_dsblty_rsn_flag
      ,p_elig_dsblty_dgr_flag           =>  p_elig_dsblty_dgr_flag
      ,p_elig_suppl_role_flag           =>  p_elig_suppl_role_flag
      ,p_elig_qual_titl_flag            =>  p_elig_qual_titl_flag
      ,p_elig_pstn_flag                 =>  p_elig_pstn_flag
      ,p_elig_prbtn_perd_flag           =>  p_elig_prbtn_perd_flag
      ,p_elig_sp_clng_prg_pt_flag       =>  p_elig_sp_clng_prg_pt_flag
      ,p_bnft_cagr_prtn_cd              =>  p_bnft_cagr_prtn_cd
      ,p_elig_dsbld_flag                =>  p_elig_dsbld_flag
      ,p_elig_ttl_cvg_vol_flag          =>  p_elig_ttl_cvg_vol_flag
      ,p_elig_ttl_prtt_flag             =>  p_elig_ttl_prtt_flag
      ,p_elig_comptncy_flag             =>  p_elig_comptncy_flag
      ,p_elig_hlth_cvg_flag		=>  p_elig_hlth_cvg_flag
      ,p_elig_anthr_pl_flag		=>  p_elig_anthr_pl_flag
      ,p_elig_qua_in_gr_flag		=>  p_elig_qua_in_gr_flag
      ,p_elig_perf_rtng_flag		=>  p_elig_perf_rtng_flag
      ,p_elig_crit_values_flag          =>  p_elig_crit_values_flag   /* RBC */
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIGY_PROFILE'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_ELIGY_PROFILE
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
  p_eligy_prfl_id := l_eligy_prfl_id;
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
    ROLLBACK TO create_ELIGY_PROFILE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_eligy_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- NOCOPY
    p_eligy_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELIGY_PROFILE;
    raise;
    --
end create_ELIGY_PROFILE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIGY_PROFILE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIGY_PROFILE
  (p_validate                       in  boolean   default false
  ,p_eligy_prfl_id                  in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_stat_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_asmt_to_use_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_elig_enrld_plip_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_cbr_quald_bnf_flag        in  varchar2  default hr_api.g_varchar2
  ,p_elig_enrld_ptip_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_dpnt_cvrd_plip_flag       in  varchar2  default hr_api.g_varchar2
  ,p_elig_dpnt_cvrd_ptip_flag       in  varchar2  default hr_api.g_varchar2
  ,p_elig_dpnt_cvrd_pgm_flag        in  varchar2  default hr_api.g_varchar2
  ,p_elig_job_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_elig_hrly_slrd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_pstl_cd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_lbr_mmbr_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_lgl_enty_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_benfts_grp_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_wk_loc_flag               in  varchar2  default hr_api.g_varchar2
  ,p_elig_brgng_unit_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_age_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_elig_los_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_typ_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_fl_tm_pt_tm_flag          in  varchar2  default hr_api.g_varchar2
  ,p_elig_ee_stat_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_grd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_elig_pct_fl_tm_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_asnt_set_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_hrs_wkd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_comp_lvl_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_org_unit_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_loa_rsn_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_pyrl_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_elig_schedd_hrs_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_py_bss_flag               in  varchar2  default hr_api.g_varchar2
  ,p_eligy_prfl_rl_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_cmbn_age_los_flag         in  varchar2  default hr_api.g_varchar2
  ,p_cntng_prtn_elig_prfl_flag      in  varchar2  default hr_api.g_varchar2
  ,p_elig_prtt_pl_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_ppl_grp_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_svc_area_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_ptip_prte_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_no_othr_cvg_flag          in  varchar2  default hr_api.g_varchar2
  ,p_elig_enrld_pl_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_enrld_oipl_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_enrld_pgm_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_dpnt_cvrd_pl_flag         in  varchar2  default hr_api.g_varchar2
  ,p_elig_lvg_rsn_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_optd_mdcr_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_tbco_use_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_dpnt_othr_ptip_flag       in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_elp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_elp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_elig_mrtl_sts_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_gndr_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_elig_dsblty_ctg_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_dsblty_rsn_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_dsblty_dgr_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_suppl_role_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_qual_titl_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_pstn_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_elig_prbtn_perd_flag           in  varchar2  default hr_api.g_varchar2
  ,p_elig_sp_clng_prg_pt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_bnft_cagr_prtn_cd              in  varchar2  default hr_api.g_varchar2
  ,p_elig_dsbld_flag                in  varchar2  default hr_api.g_varchar2
  ,p_elig_ttl_cvg_vol_flag          in  varchar2  default hr_api.g_varchar2
  ,p_elig_ttl_prtt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_comptncy_flag             in  varchar2  default hr_api.g_varchar2
  ,p_elig_hlth_cvg_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_elig_anthr_pl_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_elig_qua_in_gr_flag	    in  varchar2  default hr_api.g_varchar2
  ,p_elig_perf_rtng_flag	    in  varchar2  default hr_api.g_varchar2
  ,p_elig_crit_values_flag          in  varchar2  default hr_api.g_varchar2  /* RBC */
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIGY_PROFILE';
  l_object_version_number ben_eligy_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_eligy_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_eligy_prfl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIGY_PROFILE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIGY_PROFILE
    --
    ben_ELIGY_PROFILE_bk2.update_ELIGY_PROFILE_b
      (p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_stat_cd                        =>  p_stat_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_elig_enrld_plip_flag           =>  p_elig_enrld_plip_flag
      ,p_elig_cbr_quald_bnf_flag        =>  p_elig_cbr_quald_bnf_flag
      ,p_elig_enrld_ptip_flag           =>  p_elig_enrld_ptip_flag
      ,p_elig_dpnt_cvrd_plip_flag       =>  p_elig_dpnt_cvrd_plip_flag
      ,p_elig_dpnt_cvrd_ptip_flag       =>  p_elig_dpnt_cvrd_ptip_flag
      ,p_elig_dpnt_cvrd_pgm_flag        =>  p_elig_dpnt_cvrd_pgm_flag
      ,p_elig_job_flag                  =>  p_elig_job_flag
      ,p_elig_hrly_slrd_flag            =>  p_elig_hrly_slrd_flag
      ,p_elig_pstl_cd_flag              =>  p_elig_pstl_cd_flag
      ,p_elig_lbr_mmbr_flag             =>  p_elig_lbr_mmbr_flag
      ,p_elig_lgl_enty_flag             =>  p_elig_lgl_enty_flag
      ,p_elig_benfts_grp_flag           =>  p_elig_benfts_grp_flag
      ,p_elig_wk_loc_flag               =>  p_elig_wk_loc_flag
      ,p_elig_brgng_unit_flag           =>  p_elig_brgng_unit_flag
      ,p_elig_age_flag                  =>  p_elig_age_flag
      ,p_elig_los_flag                  =>  p_elig_los_flag
      ,p_elig_per_typ_flag              =>  p_elig_per_typ_flag
      ,p_elig_fl_tm_pt_tm_flag          =>  p_elig_fl_tm_pt_tm_flag
      ,p_elig_ee_stat_flag              =>  p_elig_ee_stat_flag
      ,p_elig_grd_flag                  =>  p_elig_grd_flag
      ,p_elig_pct_fl_tm_flag            =>  p_elig_pct_fl_tm_flag
      ,p_elig_asnt_set_flag             =>  p_elig_asnt_set_flag
      ,p_elig_hrs_wkd_flag              =>  p_elig_hrs_wkd_flag
      ,p_elig_comp_lvl_flag             =>  p_elig_comp_lvl_flag
      ,p_elig_org_unit_flag             =>  p_elig_org_unit_flag
      ,p_elig_loa_rsn_flag              =>  p_elig_loa_rsn_flag
      ,p_elig_pyrl_flag                 =>  p_elig_pyrl_flag
      ,p_elig_schedd_hrs_flag           =>  p_elig_schedd_hrs_flag
      ,p_elig_py_bss_flag               =>  p_elig_py_bss_flag
      ,p_eligy_prfl_rl_flag             =>  p_eligy_prfl_rl_flag
      ,p_elig_cmbn_age_los_flag         =>  p_elig_cmbn_age_los_flag
      ,p_cntng_prtn_elig_prfl_flag      =>  p_cntng_prtn_elig_prfl_flag
      ,p_elig_prtt_pl_flag              =>  p_elig_prtt_pl_flag
      ,p_elig_ppl_grp_flag              =>  p_elig_ppl_grp_flag
      ,p_elig_svc_area_flag             =>  p_elig_svc_area_flag
      ,p_elig_ptip_prte_flag            =>  p_elig_ptip_prte_flag
      ,p_elig_no_othr_cvg_flag          =>  p_elig_no_othr_cvg_flag
      ,p_elig_enrld_pl_flag             =>  p_elig_enrld_pl_flag
      ,p_elig_enrld_oipl_flag           =>  p_elig_enrld_oipl_flag
      ,p_elig_enrld_pgm_flag            =>  p_elig_enrld_pgm_flag
      ,p_elig_dpnt_cvrd_pl_flag         =>  p_elig_dpnt_cvrd_pl_flag
      ,p_elig_lvg_rsn_flag              =>  p_elig_lvg_rsn_flag
      ,p_elig_optd_mdcr_flag            =>  p_elig_optd_mdcr_flag
      ,p_elig_tbco_use_flag             =>  p_elig_tbco_use_flag
      ,p_elig_dpnt_othr_ptip_flag       =>  p_elig_dpnt_othr_ptip_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_elp_attribute_category         =>  p_elp_attribute_category
      ,p_elp_attribute1                 =>  p_elp_attribute1
      ,p_elp_attribute2                 =>  p_elp_attribute2
      ,p_elp_attribute3                 =>  p_elp_attribute3
      ,p_elp_attribute4                 =>  p_elp_attribute4
      ,p_elp_attribute5                 =>  p_elp_attribute5
      ,p_elp_attribute6                 =>  p_elp_attribute6
      ,p_elp_attribute7                 =>  p_elp_attribute7
      ,p_elp_attribute8                 =>  p_elp_attribute8
      ,p_elp_attribute9                 =>  p_elp_attribute9
      ,p_elp_attribute10                =>  p_elp_attribute10
      ,p_elp_attribute11                =>  p_elp_attribute11
      ,p_elp_attribute12                =>  p_elp_attribute12
      ,p_elp_attribute13                =>  p_elp_attribute13
      ,p_elp_attribute14                =>  p_elp_attribute14
      ,p_elp_attribute15                =>  p_elp_attribute15
      ,p_elp_attribute16                =>  p_elp_attribute16
      ,p_elp_attribute17                =>  p_elp_attribute17
      ,p_elp_attribute18                =>  p_elp_attribute18
      ,p_elp_attribute19                =>  p_elp_attribute19
      ,p_elp_attribute20                =>  p_elp_attribute20
      ,p_elp_attribute21                =>  p_elp_attribute21
      ,p_elp_attribute22                =>  p_elp_attribute22
      ,p_elp_attribute23                =>  p_elp_attribute23
      ,p_elp_attribute24                =>  p_elp_attribute24
      ,p_elp_attribute25                =>  p_elp_attribute25
      ,p_elp_attribute26                =>  p_elp_attribute26
      ,p_elp_attribute27                =>  p_elp_attribute27
      ,p_elp_attribute28                =>  p_elp_attribute28
      ,p_elp_attribute29                =>  p_elp_attribute29
      ,p_elp_attribute30                =>  p_elp_attribute30
      ,p_elig_mrtl_sts_flag             =>  p_elig_mrtl_sts_flag
      ,p_elig_gndr_flag                 =>  p_elig_gndr_flag
      ,p_elig_dsblty_ctg_flag           =>  p_elig_dsblty_ctg_flag
      ,p_elig_dsblty_rsn_flag           =>  p_elig_dsblty_rsn_flag
      ,p_elig_dsblty_dgr_flag           =>  p_elig_dsblty_dgr_flag
      ,p_elig_suppl_role_flag           =>  p_elig_suppl_role_flag
      ,p_elig_qual_titl_flag            =>  p_elig_qual_titl_flag
      ,p_elig_pstn_flag                 =>  p_elig_pstn_flag
      ,p_elig_prbtn_perd_flag           =>  p_elig_prbtn_perd_flag
      ,p_elig_sp_clng_prg_pt_flag       =>  p_elig_sp_clng_prg_pt_flag
      ,p_bnft_cagr_prtn_cd              =>  p_bnft_cagr_prtn_cd
      ,p_elig_dsbld_flag                =>  p_elig_dsbld_flag
      ,p_elig_ttl_cvg_vol_flag          =>  p_elig_ttl_cvg_vol_flag
      ,p_elig_ttl_prtt_flag             =>  p_elig_ttl_prtt_flag
      ,p_elig_comptncy_flag             =>  p_elig_comptncy_flag
      ,p_elig_hlth_cvg_flag		=>  p_elig_hlth_cvg_flag
      ,p_elig_anthr_pl_flag		=>  p_elig_anthr_pl_flag
      ,p_elig_qua_in_gr_flag		=>  p_elig_qua_in_gr_flag
      ,p_elig_perf_rtng_flag		=>  p_elig_perf_rtng_flag
      ,p_elig_crit_values_flag          =>  p_elig_crit_values_flag   /* RBC */
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIGY_PROFILE'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_ELIGY_PROFILE
    --
  end;
  --
  ben_elp_upd.upd
    (p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_description                   => p_description
    ,p_stat_cd                       => p_stat_cd
    ,p_asmt_to_use_cd                => p_asmt_to_use_cd
    ,p_elig_enrld_plip_flag          => p_elig_enrld_plip_flag
    ,p_elig_cbr_quald_bnf_flag       => p_elig_cbr_quald_bnf_flag
    ,p_elig_enrld_ptip_flag          => p_elig_enrld_ptip_flag
    ,p_elig_dpnt_cvrd_plip_flag      => p_elig_dpnt_cvrd_plip_flag
    ,p_elig_dpnt_cvrd_ptip_flag      => p_elig_dpnt_cvrd_ptip_flag
    ,p_elig_dpnt_cvrd_pgm_flag       => p_elig_dpnt_cvrd_pgm_flag
    ,p_elig_job_flag                 => p_elig_job_flag
    ,p_elig_hrly_slrd_flag           => p_elig_hrly_slrd_flag
    ,p_elig_pstl_cd_flag             => p_elig_pstl_cd_flag
    ,p_elig_lbr_mmbr_flag            => p_elig_lbr_mmbr_flag
    ,p_elig_lgl_enty_flag            => p_elig_lgl_enty_flag
    ,p_elig_benfts_grp_flag          => p_elig_benfts_grp_flag
    ,p_elig_wk_loc_flag              => p_elig_wk_loc_flag
    ,p_elig_brgng_unit_flag          => p_elig_brgng_unit_flag
    ,p_elig_age_flag                 => p_elig_age_flag
    ,p_elig_los_flag                 => p_elig_los_flag
    ,p_elig_per_typ_flag             => p_elig_per_typ_flag
    ,p_elig_fl_tm_pt_tm_flag         => p_elig_fl_tm_pt_tm_flag
    ,p_elig_ee_stat_flag             => p_elig_ee_stat_flag
    ,p_elig_grd_flag                 => p_elig_grd_flag
    ,p_elig_pct_fl_tm_flag           => p_elig_pct_fl_tm_flag
    ,p_elig_asnt_set_flag            => p_elig_asnt_set_flag
    ,p_elig_hrs_wkd_flag             => p_elig_hrs_wkd_flag
    ,p_elig_comp_lvl_flag            => p_elig_comp_lvl_flag
    ,p_elig_org_unit_flag            => p_elig_org_unit_flag
    ,p_elig_loa_rsn_flag             => p_elig_loa_rsn_flag
    ,p_elig_pyrl_flag                => p_elig_pyrl_flag
    ,p_elig_schedd_hrs_flag          => p_elig_schedd_hrs_flag
    ,p_elig_py_bss_flag              => p_elig_py_bss_flag
    ,p_eligy_prfl_rl_flag            => p_eligy_prfl_rl_flag
    ,p_elig_cmbn_age_los_flag        => p_elig_cmbn_age_los_flag
    ,p_cntng_prtn_elig_prfl_flag     => p_cntng_prtn_elig_prfl_flag
    ,p_elig_prtt_pl_flag             => p_elig_prtt_pl_flag
    ,p_elig_ppl_grp_flag             => p_elig_ppl_grp_flag
    ,p_elig_svc_area_flag            => p_elig_svc_area_flag
    ,p_elig_ptip_prte_flag           => p_elig_ptip_prte_flag
    ,p_elig_no_othr_cvg_flag         => p_elig_no_othr_cvg_flag
    ,p_elig_enrld_pl_flag            => p_elig_enrld_pl_flag
    ,p_elig_enrld_oipl_flag          => p_elig_enrld_oipl_flag
    ,p_elig_enrld_pgm_flag           => p_elig_enrld_pgm_flag
    ,p_elig_dpnt_cvrd_pl_flag        => p_elig_dpnt_cvrd_pl_flag
    ,p_elig_lvg_rsn_flag             => p_elig_lvg_rsn_flag
    ,p_elig_optd_mdcr_flag           => p_elig_optd_mdcr_flag
    ,p_elig_tbco_use_flag            => p_elig_tbco_use_flag
    ,p_elig_dpnt_othr_ptip_flag      => p_elig_dpnt_othr_ptip_flag
    ,p_business_group_id             => p_business_group_id
    ,p_elp_attribute_category        => p_elp_attribute_category
    ,p_elp_attribute1                => p_elp_attribute1
    ,p_elp_attribute2                => p_elp_attribute2
    ,p_elp_attribute3                => p_elp_attribute3
    ,p_elp_attribute4                => p_elp_attribute4
    ,p_elp_attribute5                => p_elp_attribute5
    ,p_elp_attribute6                => p_elp_attribute6
    ,p_elp_attribute7                => p_elp_attribute7
    ,p_elp_attribute8                => p_elp_attribute8
    ,p_elp_attribute9                => p_elp_attribute9
    ,p_elp_attribute10               => p_elp_attribute10
    ,p_elp_attribute11               => p_elp_attribute11
    ,p_elp_attribute12               => p_elp_attribute12
    ,p_elp_attribute13               => p_elp_attribute13
    ,p_elp_attribute14               => p_elp_attribute14
    ,p_elp_attribute15               => p_elp_attribute15
    ,p_elp_attribute16               => p_elp_attribute16
    ,p_elp_attribute17               => p_elp_attribute17
    ,p_elp_attribute18               => p_elp_attribute18
    ,p_elp_attribute19               => p_elp_attribute19
    ,p_elp_attribute20               => p_elp_attribute20
    ,p_elp_attribute21               => p_elp_attribute21
    ,p_elp_attribute22               => p_elp_attribute22
    ,p_elp_attribute23               => p_elp_attribute23
    ,p_elp_attribute24               => p_elp_attribute24
    ,p_elp_attribute25               => p_elp_attribute25
    ,p_elp_attribute26               => p_elp_attribute26
    ,p_elp_attribute27               => p_elp_attribute27
    ,p_elp_attribute28               => p_elp_attribute28
    ,p_elp_attribute29               => p_elp_attribute29
    ,p_elp_attribute30               => p_elp_attribute30
    ,p_elig_mrtl_sts_flag            => p_elig_mrtl_sts_flag
    ,p_elig_gndr_flag                => p_elig_gndr_flag
    ,p_elig_dsblty_ctg_flag          => p_elig_dsblty_ctg_flag
    ,p_elig_dsblty_rsn_flag          => p_elig_dsblty_rsn_flag
    ,p_elig_dsblty_dgr_flag          => p_elig_dsblty_dgr_flag
    ,p_elig_suppl_role_flag          => p_elig_suppl_role_flag
    ,p_elig_qual_titl_flag           => p_elig_qual_titl_flag
    ,p_elig_pstn_flag                => p_elig_pstn_flag
    ,p_elig_prbtn_perd_flag          => p_elig_prbtn_perd_flag
    ,p_elig_sp_clng_prg_pt_flag      => p_elig_sp_clng_prg_pt_flag
    ,p_bnft_cagr_prtn_cd             => p_bnft_cagr_prtn_cd
    ,p_elig_dsbld_flag               => p_elig_dsbld_flag
    ,p_elig_ttl_cvg_vol_flag         => p_elig_ttl_cvg_vol_flag
    ,p_elig_ttl_prtt_flag            => p_elig_ttl_prtt_flag
    ,p_elig_comptncy_flag            => p_elig_comptncy_flag
    ,p_elig_hlth_cvg_flag	     => p_elig_hlth_cvg_flag
    ,p_elig_anthr_pl_flag	     => p_elig_anthr_pl_flag
    ,p_elig_qua_in_gr_flag	     => p_elig_qua_in_gr_flag
    ,p_elig_perf_rtng_flag	     => p_elig_perf_rtng_flag
    ,p_elig_crit_values_flag         => p_elig_crit_values_flag   /* RBC */
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIGY_PROFILE
    --
    ben_ELIGY_PROFILE_bk2.update_ELIGY_PROFILE_a
      (p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_description                    =>  p_description
      ,p_stat_cd                        =>  p_stat_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_elig_enrld_plip_flag           =>  p_elig_enrld_plip_flag
      ,p_elig_cbr_quald_bnf_flag        =>  p_elig_cbr_quald_bnf_flag
      ,p_elig_enrld_ptip_flag           =>  p_elig_enrld_ptip_flag
      ,p_elig_dpnt_cvrd_plip_flag       =>  p_elig_dpnt_cvrd_plip_flag
      ,p_elig_dpnt_cvrd_ptip_flag       =>  p_elig_dpnt_cvrd_ptip_flag
      ,p_elig_dpnt_cvrd_pgm_flag        =>  p_elig_dpnt_cvrd_pgm_flag
      ,p_elig_job_flag                  =>  p_elig_job_flag
      ,p_elig_hrly_slrd_flag            =>  p_elig_hrly_slrd_flag
      ,p_elig_pstl_cd_flag              =>  p_elig_pstl_cd_flag
      ,p_elig_lbr_mmbr_flag             =>  p_elig_lbr_mmbr_flag
      ,p_elig_lgl_enty_flag             =>  p_elig_lgl_enty_flag
      ,p_elig_benfts_grp_flag           =>  p_elig_benfts_grp_flag
      ,p_elig_wk_loc_flag               =>  p_elig_wk_loc_flag
      ,p_elig_brgng_unit_flag           =>  p_elig_brgng_unit_flag
      ,p_elig_age_flag                  =>  p_elig_age_flag
      ,p_elig_los_flag                  =>  p_elig_los_flag
      ,p_elig_per_typ_flag              =>  p_elig_per_typ_flag
      ,p_elig_fl_tm_pt_tm_flag          =>  p_elig_fl_tm_pt_tm_flag
      ,p_elig_ee_stat_flag              =>  p_elig_ee_stat_flag
      ,p_elig_grd_flag                  =>  p_elig_grd_flag
      ,p_elig_pct_fl_tm_flag            =>  p_elig_pct_fl_tm_flag
      ,p_elig_asnt_set_flag             =>  p_elig_asnt_set_flag
      ,p_elig_hrs_wkd_flag              =>  p_elig_hrs_wkd_flag
      ,p_elig_comp_lvl_flag             =>  p_elig_comp_lvl_flag
      ,p_elig_org_unit_flag             =>  p_elig_org_unit_flag
      ,p_elig_loa_rsn_flag              =>  p_elig_loa_rsn_flag
      ,p_elig_pyrl_flag                 =>  p_elig_pyrl_flag
      ,p_elig_schedd_hrs_flag           =>  p_elig_schedd_hrs_flag
      ,p_elig_py_bss_flag               =>  p_elig_py_bss_flag
      ,p_eligy_prfl_rl_flag             =>  p_eligy_prfl_rl_flag
      ,p_elig_cmbn_age_los_flag         =>  p_elig_cmbn_age_los_flag
      ,p_cntng_prtn_elig_prfl_flag      =>  p_cntng_prtn_elig_prfl_flag
      ,p_elig_prtt_pl_flag              =>  p_elig_prtt_pl_flag
      ,p_elig_ppl_grp_flag              =>  p_elig_ppl_grp_flag
      ,p_elig_svc_area_flag             =>  p_elig_svc_area_flag
      ,p_elig_ptip_prte_flag            =>  p_elig_ptip_prte_flag
      ,p_elig_no_othr_cvg_flag          =>  p_elig_no_othr_cvg_flag
      ,p_elig_enrld_pl_flag             =>  p_elig_enrld_pl_flag
      ,p_elig_enrld_oipl_flag           =>  p_elig_enrld_oipl_flag
      ,p_elig_enrld_pgm_flag            =>  p_elig_enrld_pgm_flag
      ,p_elig_dpnt_cvrd_pl_flag         =>  p_elig_dpnt_cvrd_pl_flag
      ,p_elig_lvg_rsn_flag              =>  p_elig_lvg_rsn_flag
      ,p_elig_optd_mdcr_flag            =>  p_elig_optd_mdcr_flag
      ,p_elig_tbco_use_flag             =>  p_elig_tbco_use_flag
      ,p_elig_dpnt_othr_ptip_flag       =>  p_elig_dpnt_othr_ptip_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_elp_attribute_category         =>  p_elp_attribute_category
      ,p_elp_attribute1                 =>  p_elp_attribute1
      ,p_elp_attribute2                 =>  p_elp_attribute2
      ,p_elp_attribute3                 =>  p_elp_attribute3
      ,p_elp_attribute4                 =>  p_elp_attribute4
      ,p_elp_attribute5                 =>  p_elp_attribute5
      ,p_elp_attribute6                 =>  p_elp_attribute6
      ,p_elp_attribute7                 =>  p_elp_attribute7
      ,p_elp_attribute8                 =>  p_elp_attribute8
      ,p_elp_attribute9                 =>  p_elp_attribute9
      ,p_elp_attribute10                =>  p_elp_attribute10
      ,p_elp_attribute11                =>  p_elp_attribute11
      ,p_elp_attribute12                =>  p_elp_attribute12
      ,p_elp_attribute13                =>  p_elp_attribute13
      ,p_elp_attribute14                =>  p_elp_attribute14
      ,p_elp_attribute15                =>  p_elp_attribute15
      ,p_elp_attribute16                =>  p_elp_attribute16
      ,p_elp_attribute17                =>  p_elp_attribute17
      ,p_elp_attribute18                =>  p_elp_attribute18
      ,p_elp_attribute19                =>  p_elp_attribute19
      ,p_elp_attribute20                =>  p_elp_attribute20
      ,p_elp_attribute21                =>  p_elp_attribute21
      ,p_elp_attribute22                =>  p_elp_attribute22
      ,p_elp_attribute23                =>  p_elp_attribute23
      ,p_elp_attribute24                =>  p_elp_attribute24
      ,p_elp_attribute25                =>  p_elp_attribute25
      ,p_elp_attribute26                =>  p_elp_attribute26
      ,p_elp_attribute27                =>  p_elp_attribute27
      ,p_elp_attribute28                =>  p_elp_attribute28
      ,p_elp_attribute29                =>  p_elp_attribute29
      ,p_elp_attribute30                =>  p_elp_attribute30
      ,p_elig_mrtl_sts_flag             =>  p_elig_mrtl_sts_flag
      ,p_elig_gndr_flag                 =>  p_elig_gndr_flag
      ,p_elig_dsblty_ctg_flag           =>  p_elig_dsblty_ctg_flag
      ,p_elig_dsblty_rsn_flag           =>  p_elig_dsblty_rsn_flag
      ,p_elig_dsblty_dgr_flag           =>  p_elig_dsblty_dgr_flag
      ,p_elig_suppl_role_flag           =>  p_elig_suppl_role_flag
      ,p_elig_qual_titl_flag            =>  p_elig_qual_titl_flag
      ,p_elig_pstn_flag                 =>  p_elig_pstn_flag
      ,p_elig_prbtn_perd_flag           =>  p_elig_prbtn_perd_flag
      ,p_elig_sp_clng_prg_pt_flag       =>  p_elig_sp_clng_prg_pt_flag
      ,p_bnft_cagr_prtn_cd              =>  p_bnft_cagr_prtn_cd
      ,p_elig_dsbld_flag                =>  p_elig_dsbld_flag
      ,p_elig_ttl_cvg_vol_flag          =>  p_elig_ttl_cvg_vol_flag
      ,p_elig_ttl_prtt_flag             =>  p_elig_ttl_prtt_flag
      ,p_elig_comptncy_flag             =>  p_elig_comptncy_flag
      ,p_elig_hlth_cvg_flag		=>  p_elig_hlth_cvg_flag
      ,p_elig_anthr_pl_flag		=>  p_elig_anthr_pl_flag
      ,p_elig_qua_in_gr_flag		=>  p_elig_qua_in_gr_flag
      ,p_elig_perf_rtng_flag		=>  p_elig_perf_rtng_flag
      ,p_elig_crit_values_flag          =>  p_elig_crit_values_flag   /* RBC */
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIGY_PROFILE'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_ELIGY_PROFILE
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
    ROLLBACK TO update_ELIGY_PROFILE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- NOCOPY
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_ELIGY_PROFILE;
    raise;
    --
end update_ELIGY_PROFILE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_children >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_children
  (p_eligy_prfl_id                  in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is

cursor BEN_ELIGY_PRFL_RL_F is
  select a.eligy_prfl_rl_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIGY_PRFL_RL_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIGY_PRFL_RL_F b
        where a.eligy_prfl_rl_id = b.eligy_prfl_rl_id);

cursor BEN_ELIG_AGE_PRTE_F is
  select a.elig_age_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_AGE_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_AGE_PRTE_F b
        where a.elig_age_prte_id = b.elig_age_prte_id);

cursor BEN_ELIG_ASNT_SET_PRTE_F is
  select a.elig_asnt_set_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ASNT_SET_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_ASNT_SET_PRTE_F b
        where a.elig_asnt_set_prte_id = b.elig_asnt_set_prte_id);

cursor BEN_ELIG_BENFTS_GRP_PRTE_F is
  select a.elig_benfts_grp_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_BENFTS_GRP_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_BENFTS_GRP_PRTE_F b
        where a.elig_benfts_grp_prte_id = b.elig_benfts_grp_prte_id);

cursor BEN_ELIG_BRGNG_UNIT_PRTE_F is
  select a.elig_brgng_unit_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_BRGNG_UNIT_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_BRGNG_UNIT_PRTE_F b
        where a.elig_brgng_unit_prte_id = b.elig_brgng_unit_prte_id);

cursor BEN_ELIG_CBR_QUALD_BNF_F is
  select a.elig_cbr_quald_bnf_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_CBR_QUALD_BNF_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_CBR_QUALD_BNF_F b
        where a.elig_cbr_quald_bnf_id = b.elig_cbr_quald_bnf_id);

cursor BEN_ELIG_CMBN_AGE_LOS_PRTE_F is
  select a.elig_cmbn_age_los_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_CMBN_AGE_LOS_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_CMBN_AGE_LOS_PRTE_F b
        where a.elig_cmbn_age_los_prte_id = b.elig_cmbn_age_los_prte_id);

cursor BEN_ELIG_COMP_LVL_PRTE_F is
  select a.elig_comp_lvl_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_COMP_LVL_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_COMP_LVL_PRTE_F b
        where a.elig_comp_lvl_prte_id = b.elig_comp_lvl_prte_id);

cursor BEN_ELIG_DPNT_CVRD_OTHR_PGM_F is
  select a.elig_dpnt_cvrd_othr_pgm_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DPNT_CVRD_OTHR_PGM_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_DPNT_CVRD_OTHR_PGM_F b
        where a.elig_dpnt_cvrd_othr_pgm_id = b.elig_dpnt_cvrd_othr_pgm_id);

cursor BEN_ELIG_DPNT_CVRD_OTHR_PL_F is
  select a.elig_dpnt_cvrd_othr_pl_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DPNT_CVRD_OTHR_PL_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_DPNT_CVRD_OTHR_PL_F b
        where a.elig_dpnt_cvrd_othr_pl_id = b.elig_dpnt_cvrd_othr_pl_id);

cursor BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F is
  select a.elig_dpnt_cvrd_othr_ptip_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F b
        where a.elig_dpnt_cvrd_othr_ptip_id = b.elig_dpnt_cvrd_othr_ptip_id);

cursor BEN_ELIG_DPNT_CVRD_PLIP_F is
  select a.elig_dpnt_cvrd_plip_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DPNT_CVRD_PLIP_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_DPNT_CVRD_PLIP_F b
        where a.elig_dpnt_cvrd_plip_id = b.elig_dpnt_cvrd_plip_id);

cursor BEN_ELIG_EE_STAT_PRTE_F is
  select a.elig_ee_stat_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_EE_STAT_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_EE_STAT_PRTE_F b
        where a.elig_ee_stat_prte_id = b.elig_ee_stat_prte_id);

cursor BEN_ELIG_ENRLD_ANTHR_OIPL_F is
  select a.elig_enrld_anthr_oipl_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ENRLD_ANTHR_OIPL_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_ENRLD_ANTHR_OIPL_F b
        where a.elig_enrld_anthr_oipl_id = b.elig_enrld_anthr_oipl_id);

cursor BEN_ELIG_ENRLD_ANTHR_PGM_F is
  select a.elig_enrld_anthr_pgm_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ENRLD_ANTHR_PGM_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_ENRLD_ANTHR_PGM_F b
        where a.elig_enrld_anthr_pgm_id = b.elig_enrld_anthr_pgm_id);

cursor BEN_ELIG_ENRLD_ANTHR_PLIP_F is
  select a.elig_enrld_anthr_plip_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ENRLD_ANTHR_PLIP_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_ENRLD_ANTHR_PLIP_F b
        where a.elig_enrld_anthr_plip_id = b.elig_enrld_anthr_plip_id);

cursor BEN_ELIG_ENRLD_ANTHR_PL_F is
  select a.elig_enrld_anthr_pl_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ENRLD_ANTHR_PL_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_ENRLD_ANTHR_PL_F b
        where a.elig_enrld_anthr_pl_id = b.elig_enrld_anthr_pl_id);

cursor BEN_ELIG_ENRLD_ANTHR_PTIP_F is
  select a.elig_enrld_anthr_ptip_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ENRLD_ANTHR_PTIP_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_ENRLD_ANTHR_PTIP_F b
        where a.elig_enrld_anthr_ptip_id = b.elig_enrld_anthr_ptip_id);

cursor BEN_ELIG_FL_TM_PT_TM_PRTE_F is
  select a.elig_fl_tm_pt_tm_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_FL_TM_PT_TM_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_FL_TM_PT_TM_PRTE_F b
        where a.elig_fl_tm_pt_tm_prte_id = b.elig_fl_tm_pt_tm_prte_id);

cursor BEN_ELIG_GRD_PRTE_F is
  select a.elig_grd_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_GRD_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_GRD_PRTE_F b
        where a.elig_grd_prte_id = b.elig_grd_prte_id);

cursor BEN_ELIG_HRLY_SLRD_PRTE_F is
  select a.elig_hrly_slrd_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_HRLY_SLRD_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_HRLY_SLRD_PRTE_F b
        where a.elig_hrly_slrd_prte_id = b.elig_hrly_slrd_prte_id);

cursor BEN_ELIG_HRS_WKD_PRTE_F is
  select a.elig_hrs_wkd_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_HRS_WKD_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_HRS_WKD_PRTE_F b
        where a.elig_hrs_wkd_prte_id = b.elig_hrs_wkd_prte_id);

cursor BEN_ELIG_JOB_PRTE_F is
  select a.elig_job_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_JOB_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_JOB_PRTE_F b
        where a.elig_job_prte_id = b.elig_job_prte_id);

cursor BEN_ELIG_LBR_MMBR_PRTE_F is
  select a.elig_lbr_mmbr_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_LBR_MMBR_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_LBR_MMBR_PRTE_F b
        where a.elig_lbr_mmbr_prte_id = b.elig_lbr_mmbr_prte_id);

cursor BEN_ELIG_LGL_ENTY_PRTE_F is
  select a.elig_lgl_enty_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_LGL_ENTY_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_LGL_ENTY_PRTE_F b
        where a.elig_lgl_enty_prte_id = b.elig_lgl_enty_prte_id);

cursor BEN_ELIG_LOA_RSN_PRTE_F is
  select a.elig_loa_rsn_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_LOA_RSN_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_LOA_RSN_PRTE_F b
        where a.elig_loa_rsn_prte_id = b.elig_loa_rsn_prte_id);

cursor BEN_ELIG_LOS_PRTE_F is
  select a.elig_los_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_LOS_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_LOS_PRTE_F b
        where a.elig_los_prte_id = b.elig_los_prte_id);

cursor BEN_ELIG_LVG_RSN_PRTE_F is
  select a.elig_lvg_rsn_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_LVG_RSN_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_LVG_RSN_PRTE_F b
        where a.elig_lvg_rsn_prte_id = b.elig_lvg_rsn_prte_id);

cursor BEN_ELIG_NO_OTHR_CVG_PRTE_F is
  select a.elig_no_othr_cvg_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_NO_OTHR_CVG_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_NO_OTHR_CVG_PRTE_F b
        where a.elig_no_othr_cvg_prte_id = b.elig_no_othr_cvg_prte_id);

cursor BEN_ELIG_OPTD_MDCR_PRTE_F is
  select a.elig_optd_mdcr_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_OPTD_MDCR_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_OPTD_MDCR_PRTE_F b
        where a.elig_optd_mdcr_prte_id = b.elig_optd_mdcr_prte_id);

cursor BEN_ELIG_ORG_UNIT_PRTE_F is
  select a.elig_org_unit_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ORG_UNIT_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_ORG_UNIT_PRTE_F b
        where a.elig_org_unit_prte_id = b.elig_org_unit_prte_id);

cursor BEN_ELIG_OTHR_PTIP_PRTE_F is
  select a.elig_othr_ptip_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_OTHR_PTIP_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_OTHR_PTIP_PRTE_F b
        where a.elig_othr_ptip_prte_id = b.elig_othr_ptip_prte_id);

cursor BEN_ELIG_DPNT_OTHR_PTIP_F is
  select a.elig_dpnt_othr_ptip_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DPNT_OTHR_PTIP_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_DPNT_OTHR_PTIP_F b
        where a.elig_dpnt_othr_ptip_id = b.elig_dpnt_othr_ptip_id);

cursor BEN_ELIG_PCT_FL_TM_PRTE_F is
  select a.elig_pct_fl_tm_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PCT_FL_TM_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_PCT_FL_TM_PRTE_F b
        where a.elig_pct_fl_tm_prte_id = b.elig_pct_fl_tm_prte_id);

cursor BEN_ELIG_PER_TYP_PRTE_F is
  select a.elig_per_typ_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PER_TYP_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_PER_TYP_PRTE_F b
        where a.elig_per_typ_prte_id = b.elig_per_typ_prte_id);

cursor BEN_ELIG_PPL_GRP_PRTE_F is
  select a.elig_ppl_grp_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PPL_GRP_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_PPL_GRP_PRTE_F b
        where a.elig_ppl_grp_prte_id = b.elig_ppl_grp_prte_id);

cursor BEN_ELIG_PRTT_ANTHR_PL_PRTE_F is
  select a.elig_prtt_anthr_pl_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PRTT_ANTHR_PL_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_PRTT_ANTHR_PL_PRTE_F b
        where a.elig_prtt_anthr_pl_prte_id = b.elig_prtt_anthr_pl_prte_id);

cursor BEN_ELIG_PSTL_CD_R_RNG_PRTE_F is
  select a.elig_pstl_cd_r_rng_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PSTL_CD_R_RNG_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_PSTL_CD_R_RNG_PRTE_F b
        where a.elig_pstl_cd_r_rng_prte_id = b.elig_pstl_cd_r_rng_prte_id);

cursor BEN_ELIG_PYRL_PRTE_F is
  select a.elig_pyrl_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PYRL_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_PYRL_PRTE_F b
        where a.elig_pyrl_prte_id = b.elig_pyrl_prte_id);

cursor BEN_ELIG_PY_BSS_PRTE_F is
  select a.elig_py_bss_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PY_BSS_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_PY_BSS_PRTE_F b
        where a.elig_py_bss_prte_id = b.elig_py_bss_prte_id);

cursor BEN_ELIG_SCHEDD_HRS_PRTE_F is
  select a.elig_schedd_hrs_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_SCHEDD_HRS_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_SCHEDD_HRS_PRTE_F b
        where a.elig_schedd_hrs_prte_id = b.elig_schedd_hrs_prte_id);

cursor BEN_ELIG_SVC_AREA_PRTE_F is
  select a.elig_svc_area_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_SVC_AREA_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_SVC_AREA_PRTE_F b
        where a.elig_svc_area_prte_id = b.elig_svc_area_prte_id);

cursor BEN_ELIG_WK_LOC_PRTE_F is
  select a.elig_wk_loc_prte_id, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_WK_LOC_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_ELIG_WK_LOC_PRTE_F b
        where a.elig_wk_loc_prte_id = b.elig_wk_loc_prte_id);

cursor BEN_PRTN_ELIG_PRFL_F is
  select a.prtn_elig_prfl_id, a.object_version_number, a.effective_end_date eed
  from BEN_PRTN_ELIG_PRFL_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_PRTN_ELIG_PRFL_F b
        where a.prtn_elig_prfl_id = b.prtn_elig_prfl_id);


cursor BEN_CNTNG_PRTN_ELIG_PRFL_F is
  select a.cntng_prtn_elig_prfl_id, a.object_version_number, a.effective_end_date eed
  from BEN_CNTNG_PRTN_ELIG_PRFL_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and a.effective_end_date = (select max(b.effective_end_date)
        from BEN_CNTNG_PRTN_ELIG_PRFL_F b
        where a.cntng_prtn_elig_prfl_id = b.cntng_prtn_elig_prfl_id);



cursor BEN_ELIG_GNDR_PRTE_F is
  select a.ELIG_GNDR_PRTE_ID, a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_GNDR_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;


cursor  BEN_ELIG_MRTL_STS_PRTE_F is
  select a.ELIG_MRTL_STS_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_MRTL_STS_PRTE_F a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_DSBLTY_CTG_PRTE_F is
  select a.ELIG_DSBLTY_CTG_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DSBLTY_CTG_PRTE_f a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_DSBLTY_RSN_PRTE_F is
  select a.ELIG_DSBLTY_RSN_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DSBLTY_RSN_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_DSBLTY_DGR_PRTE_F is
  select a.ELIG_DSBLTY_DGR_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DSBLTY_DGR_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_Suppl_role_prte_f is
  select a.ELIG_Suppl_role_prte_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_Suppl_role_prte_f  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_qual_titl_prte_f is
  select a.ELIG_qual_titl_prte_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_qual_titl_prte_f  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;


cursor  BEN_ELIG_pstn_prte_f is
  select a.ELIG_pstn_prte_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_pstn_prte_f  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_prbtn_perd_prte_f is
  select a.ELIG_prbtn_perd_prte_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_prbtn_perd_prte_f  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_sp_clng_prg_prte_f is
  select a.ELIG_sp_clng_prg_prte_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_sp_clng_prg_prte_f  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_DSBLD_PRTE_F is
  select a.ELIG_DSBLD_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_DSBLD_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_TTL_CVG_VOL_PRTE_F is
  select a.ELIG_TTL_CVG_VOL_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_TTL_CVG_VOL_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_TTL_PRTT_PRTE_F is
  select a.ELIG_TTL_PRTT_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_TTL_PRTT_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_ANTHR_PL_PRTE_F is
  select a.ELIG_ANTHR_PL_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_ANTHR_PL_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_HLTH_CVG_PRTE_F is
  select a.ELIG_HLTH_CVG_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_HLTH_CVG_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_COMPTNCY_PRTE_F is
  select a.ELIG_COMPTNCY_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_COMPTNCY_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_QUA_IN_GR_PRTE_F is
  select a.ELIG_QUA_IN_GR_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_QUA_IN_GR_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;

cursor  BEN_ELIG_PERF_RTNG_PRTE_F is
  select a.ELIG_PERF_RTNG_PRTE_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIG_PERF_RTNG_PRTE_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;
--
-- Bug No 4411798
--
cursor  BEN_ELIGY_CRIT_VALUES_F is
  select a.ELIGY_CRIT_VALUES_ID , a.object_version_number, a.effective_end_date eed
  from BEN_ELIGY_CRIT_VALUES_F  a
  where a.eligy_prfl_id = p_eligy_prfl_id
    and p_effective_date between   a.effective_start_date and a.effective_end_date ;
--
-- End Bug No 4411798
--
l_row BEN_ELIGY_PRFL_RL_F%rowtype;
l_effective_start_date date;
l_effective_end_date   date;
l_effective_date       date;

begin
  -- delete all children records of the eligy-prfl
  --
  -- These tables are in bendev11 as children, but the table are not used in our
  -- product at this time:
  --         BEN_ELIG_DPNT_CVRD_OTHR_OIPL_F
  --         BEN_ELIG_DSBLD_STAT_PRTE_F
  --         BEN_ELIG_MLTRY_STAT_PRTE_F
  --         BEN_ELIG_PRTT_ANTHR_PGM_F
  for l_row in BEN_ELIGY_PRFL_RL_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIGY_PROFILE_RULE_api.delete_ELIGY_PROFILE_RULE
         (p_validate                       => false
         ,p_eligy_prfl_rl_id               => l_row.eligy_prfl_rl_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_AGE_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIG_AGE_PRTE_api.delete_ELIG_AGE_PRTE
         (p_validate                       => false
         ,p_elig_age_prte_id               => l_row.elig_age_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_ASNT_SET_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ASNT_SET_PRTE_api.delete_ELIG_ASNT_SET_PRTE
         (p_validate                       => false
         ,p_elig_asnt_set_prte_id          => l_row.elig_asnt_set_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_BENFTS_GRP_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_BENFTS_GRP_PRTE_api.delete_ELIG_BENFTS_GRP_PRTE
         (p_validate                       => false
         ,p_elig_benfts_grp_prte_id        => l_row.elig_benfts_grp_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_BRGNG_UNIT_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_BRGNG_UNIT_PRTE_api.delete_ELIG_BRGNG_UNIT_PRTE
         (p_validate                       => false
         ,p_elig_brgng_unit_prte_id        => l_row.elig_brgng_unit_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_CBR_QUALD_BNF_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_CBR_QUALD_BNF_api.delete_ELIG_CBR_QUALD_BNF
         (p_validate                       => false
         ,p_elig_cbr_quald_bnf_id          => l_row.elig_cbr_quald_bnf_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_CMBN_AGE_LOS_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIG_CMBN_AGE_LOS_api.delete_ELIG_CMBN_AGE_LOS
         (p_validate                       => false
         ,p_elig_cmbn_age_los_prte_id      => l_row.elig_cmbn_age_los_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_COMP_LVL_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_COMP_LVL_PRTE_api.delete_ELIG_COMP_LVL_PRTE
         (p_validate                       => false
         ,p_elig_comp_lvl_prte_id          => l_row.elig_comp_lvl_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_DPNT_CVRD_OTHR_PGM_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIG_DPNT_CVRD_O_PGM_api.delete_ELIG_DPNT_CVRD_O_PGM
         (p_validate                       => false
         ,p_elig_dpnt_cvrd_othr_pgm_id     => l_row.elig_dpnt_cvrd_othr_pgm_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_DPNT_CVRD_OTHR_PL_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIG_DPNT_CVD_OTHR_PL_api.delete_ELIG_DPNT_CVD_OTHR_PL
         (p_validate                       => false
         ,p_elig_dpnt_cvrd_othr_pl_id      => l_row.elig_dpnt_cvrd_othr_pl_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIG_DPNT_CVRD_O_PTIP_api.delete_ELIG_DPNT_CVRD_O_PTIP
         (p_validate                       => false
         ,p_elig_dpnt_cvrd_othr_ptip_id     => l_row.elig_dpnt_cvrd_othr_ptip_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_DPNT_CVRD_PLIP_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIG_DPNT_CVRD_PLIP_api.delete_ELIG_DPNT_CVRD_PLIP
         (p_validate                       => false
         ,p_elig_dpnt_cvrd_plip_id         => l_row.elig_dpnt_cvrd_plip_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_EE_STAT_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_EE_STAT_PRTE_api.delete_ELIG_EE_STAT_PRTE
         (p_validate                       => false
         ,p_elig_ee_stat_prte_id           => l_row.elig_ee_stat_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_ENRLD_ANTHR_OIPL_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ENRLD_ANTHR_OIPL_api.delete_ELIG_ENRLD_ANTHR_OIPL
         (p_validate                       => false
         ,p_elig_enrld_anthr_oipl_id       => l_row.elig_enrld_anthr_oipl_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_ENRLD_ANTHR_PGM_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ENRLD_ANTHR_PGM_api.delete_ELIG_ENRLD_ANTHR_PGM
         (p_validate                       => false
         ,p_elig_enrld_anthr_pgm_id        => l_row.elig_enrld_anthr_pgm_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_ENRLD_ANTHR_PLIP_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ENRLD_ANTHR_PLIP_api.delete_ELIG_ENRLD_ANTHR_PLIP
         (p_validate                       => false
         ,p_elig_enrld_anthr_plip_id       => l_row.elig_enrld_anthr_plip_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_ENRLD_ANTHR_PL_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ENRLD_ANTHR_PL_api.delete_ELIG_ENRLD_ANTHR_PL
         (p_validate                       => false
         ,p_elig_enrld_anthr_pl_id         => l_row.elig_enrld_anthr_pl_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_ENRLD_ANTHR_PTIP_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ENRLD_ANTHR_PTIP_api.delete_ELIG_ENRLD_ANTHR_PTIP
         (p_validate                       => false
         ,p_elig_enrld_anthr_ptip_id       => l_row.elig_enrld_anthr_ptip_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_FL_TM_PT_TM_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_FL_TM_PT_TM_PRTE_api.delete_ELIG_FL_TM_PT_TM_PRTE
         (p_validate                       => false
         ,p_elig_fl_tm_pt_tm_prte_id         => l_row.elig_fl_tm_pt_tm_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_GRD_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_GRD_PRTE_api.delete_ELIG_GRD_PRTE
         (p_validate                       => false
         ,p_elig_grd_prte_id                 => l_row.elig_grd_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_HRLY_SLRD_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_HRLY_SLRD_PRTE_api.delete_ELIG_HRLY_SLRD_PRTE
         (p_validate                       => false
         ,p_elig_hrly_slrd_prte_id           => l_row.elig_hrly_slrd_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_HRS_WKD_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_HRS_WKD_PRTE_api.delete_ELIG_HRS_WKD_PRTE
         (p_validate                       => false
         ,p_elig_hrs_wkd_prte_id       => l_row.elig_hrs_wkd_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_JOB_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIGY_JOB_PRTE_api.delete_ELIGY_JOB_PRTE
         (p_validate                       => false
         ,p_elig_job_prte_id               => l_row.elig_job_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_LBR_MMBR_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_LBR_MMBR_PRTE_api.delete_ELIG_LBR_MMBR_PRTE
         (p_validate                       => false
         ,p_elig_lbr_mmbr_prte_id          => l_row.elig_lbr_mmbr_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_LGL_ENTY_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_LGL_ENTY_PRTE_api.delete_ELIG_LGL_ENTY_PRTE
         (p_validate                       => false
         ,p_elig_lgl_enty_prte_id          => l_row.elig_lgl_enty_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_LOA_RSN_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_LOA_RSN_PRTE_api.delete_ELIG_LOA_RSN_PRTE
         (p_validate                       => false
         ,p_elig_loa_rsn_prte_id               => l_row.elig_loa_rsn_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_LOS_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_LOS_PRTE_api.delete_ELIG_LOS_PRTE
         (p_validate                       => false
         ,p_elig_los_prte_id               => l_row.elig_los_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_LVG_RSN_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_LVG_RSN_PRTE_api.delete_ELIG_LVG_RSN_PRTE
         (p_validate                       => false
         ,p_elig_lvg_rsn_prte_id           => l_row.elig_lvg_rsn_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_NO_OTHR_CVG_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_NO_OTHR_CVG_PRTE_api.delete_ELIG_NO_OTHR_CVG_PRTE
         (p_validate                       => false
         ,p_elig_no_othr_cvg_prte_id       => l_row.elig_no_othr_cvg_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_OPTD_MDCR_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_OPTD_MDCR_PRTE_api.delete_ELIG_OPTD_MDCR_PRTE
         (p_validate                       => false
         ,p_elig_optd_mdcr_prte_id         => l_row.elig_optd_mdcr_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_ORG_UNIT_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ORG_UNIT_PRTE_api.delete_ELIG_ORG_UNIT_PRTE
         (p_validate                       => false
         ,p_elig_org_unit_prte_id          => l_row.elig_org_unit_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_OTHR_PTIP_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_OTHR_PTIP_PRTE_api.delete_ELIG_OTHR_PTIP_PRTE
         (p_validate                       => false
         ,p_elig_othr_ptip_prte_id         => l_row.elig_othr_ptip_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_DPNT_OTHR_PTIP_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_DPNT_OTHR_PTIP_api.delete_ELIG_DPNT_OTHR_PTIP
         (p_validate                       => false
         ,p_elig_dpnt_othr_ptip_id         => l_row.elig_dpnt_othr_ptip_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_PCT_FL_TM_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_PCT_FL_TM_PRTE_api.delete_ELIG_PCT_FL_TM_PRTE
         (p_validate                       => false
         ,p_elig_pct_fl_tm_prte_id         => l_row.elig_pct_fl_tm_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_PER_TYP_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_PER_TYP_PRTE_api.delete_ELIG_PER_TYP_PRTE
         (p_validate                       => false
         ,p_elig_per_typ_prte_id           => l_row.elig_per_typ_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_PPL_GRP_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_PPL_GRP_PRTE_api.delete_ELIG_PPL_GRP_PRTE
         (p_validate                       => false
         ,p_elig_ppl_grp_prte_id           => l_row.elig_ppl_grp_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_PRTT_ANTHR_PL_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELG_PRT_ANTHR_PL_PT_api.delete_ELG_PRT_ANTHR_PL_PT
         (p_validate                       => false
         ,p_elig_prtt_anthr_pl_prte_id     => l_row.elig_prtt_anthr_pl_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_PSTL_CD_R_RNG_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         ben_ELIG_PSTL_CD_RNG_PRTE_api.delete_ELIG_PSTL_CD_RNG_PRTE
         (p_validate                       => false
         ,p_elig_pstl_cd_r_rng_prte_id     => l_row.elig_pstl_cd_r_rng_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_PYRL_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_PYRL_PRTE_api.delete_ELIG_PYRL_PRTE
         (p_validate                       => false
         ,p_elig_pyrl_prte_id              => l_row.elig_pyrl_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_PY_BSS_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_PY_BSS_PRTE_api.delete_ELIG_PY_BSS_PRTE
         (p_validate                       => false
         ,p_elig_py_bss_prte_id            => l_row.elig_py_bss_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_SCHEDD_HRS_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_SCHEDD_HRS_PRTE_api.delete_ELIG_SCHEDD_HRS_PRTE
         (p_validate                       => false
         ,p_elig_schedd_hrs_prte_id        => l_row.elig_schedd_hrs_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_SVC_AREA_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_SVC_AREA_PRTE_api.delete_ELIG_SVC_AREA_PRTE
         (p_validate                       => false
         ,p_elig_svc_area_prte_id          => l_row.elig_svc_area_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_ELIG_WK_LOC_PRTE_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_WK_LOC_PRTE_api.delete_ELIG_WK_LOC_PRTE
         (p_validate                       => false
         ,p_elig_wk_loc_prte_id            => l_row.elig_wk_loc_prte_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
  for l_row in BEN_PRTN_ELIG_PRFL_F loop
      if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_PRTN_ELIG_PRFL_api.delete_PRTN_ELIG_PRFL
         (p_validate                       => false
         ,p_prtn_elig_prfl_id              => l_row.prtn_elig_prfl_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in BEN_CNTNG_PRTN_ELIG_PRFL_F loop
         if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
         or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else l_effective_date := p_effective_date;
         end if;
         BEN_CNTNG_PRTN_ELIG_PRFL_api.delete_CNTNG_PRTN_ELIG_PRFL
         (p_validate                       => false
         ,p_cntng_prtn_elig_prfl_id              => l_row.cntng_prtn_elig_prfl_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => l_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;


  for l_row in BEN_ELIG_GNDR_PRTE_F loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_GNDR_PRTE_api.delete_ELIG_GNDR_PRTE
         (p_validate                       => false
         ,p_ELIG_GNDR_PRTE_ID         => l_row.ELIG_GNDR_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;


  for l_row in BEN_ELIG_MRTL_STS_PRTE_F loop
         BEN_ELIG_MRTL_STS_PRTE_api.delete_ELIG_MRTL_STS_PRTE
         (p_validate                       => false
         ,p_ELIG_MRTL_STS_PRTE_ID          => l_row.ELIG_MRTL_STS_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;

  for l_row in BEN_ELIG_DSBLTY_CTG_PRTE_F loop
         BEN_ELIG_DSBLTY_CTG_PRTE_api.delete_ELIG_DSBLTY_CTG_PRTE
         (p_validate                       => false
         ,p_ELIG_DSBLTY_CTG_PRTE_ID        => l_row.ELIG_DSBLTY_CTG_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;


    for l_row in BEN_ELIG_DSBLTY_RSN_PRTE_F loop
         BEN_ELIG_DSBLTY_RSN_PRTE_api.delete_ELIG_DSBLTY_RSN_PRTE
         (p_validate                       => false
         ,p_ELIG_DSBLTY_RSN_PRTE_ID        => l_row.ELIG_DSBLTY_RSN_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;

  for l_row in BEN_ELIG_DSBLTY_DGR_PRTE_F loop
         BEN_ELIG_DSBLTY_DGR_PRTE_api.delete_ELIG_DSBLTY_DGR_PRTE
         (p_validate                       => false
         ,p_ELIG_DSBLTY_DGR_PRTE_ID        => l_row.ELIG_DSBLTY_DGR_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;


  for l_row in BEN_ELIG_DSBLTY_DGR_PRTE_F loop
         BEN_ELIG_DSBLTY_DGR_PRTE_api.delete_ELIG_DSBLTY_DGR_PRTE
         (p_validate                       => false
         ,p_ELIG_DSBLTY_DGR_PRTE_ID        => l_row.ELIG_DSBLTY_DGR_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;

  for l_row in BEN_ELIG_Suppl_role_prte_f  loop
         BEN_ELIG_Suppl_role_prte_api.delete_ELIG_Suppl_role_prte
         (p_validate                       => false
         ,p_ELIG_Suppl_role_prte_ID        => l_row.ELIG_Suppl_role_prte_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;


  for l_row in   BEN_ELIG_qual_titl_prte_f  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_qual_titl_prte_api.delete_ELIG_qual_titl_prte
         (p_validate                       => false
         ,p_ELIG_qual_titl_prte_ID          => l_row.ELIG_qual_titl_prte_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_pstn_prte_f  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_pstn_prte_api.delete_ELIG_pstn_prte
         (p_validate                       => false
         ,p_ELIG_pstn_prte_ID              => l_row.ELIG_pstn_prte_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_prbtn_perd_prte_f  loop
         BEN_ELIG_prbtn_perd_prte_api.delete_ELIG_prbtn_perd_prte
         (p_validate                       => false
         ,p_ELIG_prbtn_perd_prte_ID        => l_row.ELIG_prbtn_perd_prte_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;

  for l_row in   BEN_ELIG_sp_clng_prg_prte_f  loop
         BEN_ELIG_sp_clng_prg_prte_api.delete_ELIG_sp_clng_prg_prte
         (p_validate                       => false
         ,p_ELIG_sp_clng_prg_prte_ID       => l_row.ELIG_sp_clng_prg_prte_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
  end loop;

  for l_row in   BEN_ELIG_DSBLD_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_DSBLD_PRTE_api.delete_ELIG_DSBLD_PRTE
         (p_validate                       => false
         ,p_ELIG_DSBLD_PRTE_ID             => l_row.ELIG_DSBLD_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_TTL_CVG_VOL_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_TTL_CVG_VOL_PRTE_api.delete_ELIG_TTL_CVG_VOL_PRTE
         (p_validate                       => false
         ,p_ELIG_TTL_CVG_VOL_PRTE_ID       => l_row.ELIG_TTL_CVG_VOL_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_TTL_PRTT_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_TTL_PRTT_PRTE_api.delete_ELIG_TTL_PRTT_PRTE
         (p_validate                       => false
         ,p_ELIG_TTL_PRTT_PRTE_ID          => l_row.ELIG_TTL_PRTT_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_ANTHR_PL_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_ANTHR_PL_PRTE_api.delete_ELIG_ANTHR_PL_PRTE
         (p_validate                       => false
         ,p_ELIG_ANTHR_PL_PRTE_ID          => l_row.ELIG_ANTHR_PL_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_HLTH_CVG_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_HLTH_CVG_PRTE_api.delete_ELIG_HLTH_CVG_PRTE
         (p_validate                       => false
         ,p_ELIG_HLTH_CVG_PRTE_ID          => l_row.ELIG_HLTH_CVG_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_COMPTNCY_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_COMPTNCY_PRTE_api.delete_ELIG_COMPTNCY_PRTE
         (p_validate                       => false
         ,p_ELIG_COMPTNCY_PRTE_ID          => l_row.ELIG_COMPTNCY_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_QUA_IN_GR_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_QUA_IN_GR_PRTE_api.delete_ELIG_QUA_IN_GR_PRTE
         (p_validate                       => false
         ,p_ELIG_QUA_IN_GR_PRTE_ID         => l_row.ELIG_QUA_IN_GR_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

  for l_row in   BEN_ELIG_PERF_RTNG_PRTE_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         BEN_ELIG_PERF_RTNG_PRTE_api.delete_ELIG_PERF_RTNG_PRTE
         (p_validate                       => false
         ,p_ELIG_PERF_RTNG_PRTE_ID         => l_row.ELIG_PERF_RTNG_PRTE_ID
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;

--
-- Bug No 4411798
--
  for l_row in   BEN_ELIGY_CRIT_VALUES_F  loop
     if (p_datetrack_mode = hr_api.g_delete and l_row.eed > p_effective_date)
            or p_datetrack_mode <> hr_api.g_delete then
         if p_datetrack_mode = hr_api.g_zap then
            l_effective_date := l_row.eed;
         else
            l_effective_date := p_effective_date;
         end if;
         ben_eligy_crit_values_api.delete_eligy_crit_values
         (p_validate                       => false
         ,p_eligy_crit_values_id           => l_row.eligy_crit_values_id
         ,p_effective_start_date           => l_effective_start_date
         ,p_effective_end_date             => l_effective_end_date
         ,p_object_version_number          => l_row.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_datetrack_mode                 => p_datetrack_mode);
     end if;
  end loop;
--
-- End of Bug No 4411798
--

end delete_children;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIGY_PROFILE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGY_PROFILE
  (p_validate                       in  boolean  default false
  ,p_eligy_prfl_id                  in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIGY_PROFILE';
  l_object_version_number ben_eligy_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_eligy_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_eligy_prfl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIGY_PROFILE;
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
    -- Start of API User Hook for the before hook of delete_ELIGY_PROFILE
    --
    ben_ELIGY_PROFILE_bk3.delete_ELIGY_PROFILE_b
      (p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIGY_PROFILE'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_ELIGY_PROFILE
    --
  end;

  delete_children
    (p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);

  ben_elp_del.del
    (p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);

  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIGY_PROFILE
    --
    ben_ELIGY_PROFILE_bk3.delete_ELIGY_PROFILE_a
      (p_eligy_prfl_id                  =>  p_eligy_prfl_id
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
        (p_module_name => 'DELETE_ELIGY_PROFILE'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_ELIGY_PROFILE
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
    ROLLBACK TO delete_ELIGY_PROFILE;
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
    -- NOCOPY
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ELIGY_PROFILE;
    raise;
    --
end delete_ELIGY_PROFILE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_eligy_prfl_id                  in     number
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
  ben_elp_shd.lck
    (p_eligy_prfl_id              => p_eligy_prfl_id
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
end ben_ELIGY_PROFILE_api;

/
