--------------------------------------------------------
--  DDL for Package Body BEN_VRBL_RATE_PROFILE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VRBL_RATE_PROFILE_API" as
/* $Header: bevpfapi.pkb 115.15 2003/08/19 15:46:19 mmudigon ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_vrbl_rate_profile_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_vrbl_rate_profile >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vrbl_rate_profile
  (p_validate                       in  boolean   default false
  ,p_vrbl_rt_prfl_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_typ_opt_typ_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_acty_typ_cd                    in  varchar2  default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_tx_typ_cd                      in  varchar2  default null
  ,p_vrbl_rt_trtmt_cd               in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_mlt_cd                         in  varchar2  default null
  ,p_incrmnt_elcn_val               in  number    default null
  ,p_dflt_elcn_val                  in  number    default null
  ,p_mx_elcn_val                    in  number    default null
  ,p_mn_elcn_val                    in  number    default null
  ,p_lwr_lmt_val                    in  number    default null
  ,p_lwr_lmt_calc_rl                in  number    default null
  ,p_upr_lmt_val                    in  number    default null
  ,p_upr_lmt_calc_rl                in  number    default null
  ,p_ultmt_upr_lmt                  in  number    default null
  ,p_ultmt_lwr_lmt                  in  number    default null
  ,p_ultmt_upr_lmt_calc_rl          in  number    default null
  ,p_ultmt_lwr_lmt_calc_rl          in  number    default null
  ,p_ann_mn_elcn_val                in  number    default null
  ,p_ann_mx_elcn_val                in  number    default null
  ,p_val                            in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_no_mn_elcn_val_dfnd_flag       in  varchar2  default 'N'
  ,p_no_mx_elcn_val_dfnd_flag       in  varchar2  default 'N'
  ,p_alwys_sum_all_cvg_flag         in  varchar2  default 'N'
  ,p_alwys_cnt_all_prtts_flag       in  varchar2  default 'N'
  ,p_val_calc_rl                    in  number    default null
  ,p_vrbl_rt_prfl_stat_cd           in  varchar2  default null
  ,p_vrbl_usg_cd                    in  varchar2  default null
  ,p_asmt_to_use_cd                 in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_rt_hrly_slrd_flag              in  varchar2  default 'N'
  ,p_rt_pstl_cd_flag                in  varchar2  default 'N'
  ,p_rt_lbr_mmbr_flag               in  varchar2  default 'N'
  ,p_rt_lgl_enty_flag               in  varchar2  default 'N'
  ,p_rt_benfts_grp_flag             in  varchar2  default 'N'
  ,p_rt_wk_loc_flag                 in  varchar2  default 'N'
  ,p_rt_brgng_unit_flag             in  varchar2  default 'N'
  ,p_rt_age_flag                    in  varchar2  default 'N'
  ,p_rt_los_flag                    in  varchar2  default 'N'
  ,p_rt_per_typ_flag                in  varchar2  default 'N'
  ,p_rt_fl_tm_pt_tm_flag            in  varchar2  default 'N'
  ,p_rt_ee_stat_flag                in  varchar2  default 'N'
  ,p_rt_grd_flag                    in  varchar2  default 'N'
  ,p_rt_pct_fl_tm_flag              in  varchar2  default 'N'
  ,p_rt_asnt_set_flag               in  varchar2  default 'N'
  ,p_rt_hrs_wkd_flag                in  varchar2  default 'N'
  ,p_rt_comp_lvl_flag               in  varchar2  default 'N'
  ,p_rt_org_unit_flag               in  varchar2  default 'N'
  ,p_rt_loa_rsn_flag                in  varchar2  default 'N'
  ,p_rt_pyrl_flag                   in  varchar2  default 'N'
  ,p_rt_schedd_hrs_flag             in  varchar2  default 'N'
  ,p_rt_py_bss_flag                 in  varchar2  default 'N'
  ,p_rt_prfl_rl_flag                in  varchar2  default 'N'
  ,p_rt_cmbn_age_los_flag           in  varchar2  default 'N'
  ,p_rt_prtt_pl_flag                in  varchar2  default 'N'
  ,p_rt_svc_area_flag               in  varchar2  default 'N'
  ,p_rt_ppl_grp_flag                in  varchar2  default 'N'
  ,p_rt_dsbld_flag                  in  varchar2  default 'N'
  ,p_rt_hlth_cvg_flag               in  varchar2  default 'N'
  ,p_rt_poe_flag                    in  varchar2  default 'N'
  ,p_rt_ttl_cvg_vol_flag            in  varchar2  default 'N'
  ,p_rt_ttl_prtt_flag               in  varchar2  default 'N'
  ,p_rt_gndr_flag                   in  varchar2  default 'N'
  ,p_rt_tbco_use_flag               in  varchar2  default 'N'
  ,p_vpf_attribute_category         in  varchar2  default null
  ,p_vpf_attribute1                 in  varchar2  default null
  ,p_vpf_attribute2                 in  varchar2  default null
  ,p_vpf_attribute3                 in  varchar2  default null
  ,p_vpf_attribute4                 in  varchar2  default null
  ,p_vpf_attribute5                 in  varchar2  default null
  ,p_vpf_attribute6                 in  varchar2  default null
  ,p_vpf_attribute7                 in  varchar2  default null
  ,p_vpf_attribute8                 in  varchar2  default null
  ,p_vpf_attribute9                 in  varchar2  default null
  ,p_vpf_attribute10                in  varchar2  default null
  ,p_vpf_attribute11                in  varchar2  default null
  ,p_vpf_attribute12                in  varchar2  default null
  ,p_vpf_attribute13                in  varchar2  default null
  ,p_vpf_attribute14                in  varchar2  default null
  ,p_vpf_attribute15                in  varchar2  default null
  ,p_vpf_attribute16                in  varchar2  default null
  ,p_vpf_attribute17                in  varchar2  default null
  ,p_vpf_attribute18                in  varchar2  default null
  ,p_vpf_attribute19                in  varchar2  default null
  ,p_vpf_attribute20                in  varchar2  default null
  ,p_vpf_attribute21                in  varchar2  default null
  ,p_vpf_attribute22                in  varchar2  default null
  ,p_vpf_attribute23                in  varchar2  default null
  ,p_vpf_attribute24                in  varchar2  default null
  ,p_vpf_attribute25                in  varchar2  default null
  ,p_vpf_attribute26                in  varchar2  default null
  ,p_vpf_attribute27                in  varchar2  default null
  ,p_vpf_attribute28                in  varchar2  default null
  ,p_vpf_attribute29                in  varchar2  default null
  ,p_vpf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_rt_cntng_prtn_prfl_flag	    in  varchar2  default null
  ,p_rt_cbr_quald_bnf_flag  	    in  varchar2  default null
  ,p_rt_optd_mdcr_flag      	    in  varchar2  default null
  ,p_rt_lvg_rsn_flag        	    in  varchar2  default null
  ,p_rt_pstn_flag           	    in  varchar2  default null
  ,p_rt_comptncy_flag       	    in  varchar2  default null
  ,p_rt_job_flag            	    in  varchar2  default null
  ,p_rt_qual_titl_flag      	    in  varchar2  default null
  ,p_rt_dpnt_cvrd_pl_flag   	    in  varchar2  default null
  ,p_rt_dpnt_cvrd_plip_flag 	    in  varchar2  default null
  ,p_rt_dpnt_cvrd_ptip_flag 	    in  varchar2  default null
  ,p_rt_dpnt_cvrd_pgm_flag  	    in  varchar2  default null
  ,p_rt_enrld_oipl_flag     	    in  varchar2  default null
  ,p_rt_enrld_pl_flag       	    in  varchar2  default null
  ,p_rt_enrld_plip_flag     	    in  varchar2  default null
  ,p_rt_enrld_ptip_flag     	    in  varchar2  default null
  ,p_rt_enrld_pgm_flag      	    in  varchar2  default null
  ,p_rt_prtt_anthr_pl_flag  	    in  varchar2  default null
  ,p_rt_othr_ptip_flag      	    in  varchar2  default null
  ,p_rt_no_othr_cvg_flag    	    in  varchar2  default null
  ,p_rt_dpnt_othr_ptip_flag 	    in  varchar2  default null
  ,p_rt_qua_in_gr_flag        	    in  varchar2  default null
  ,p_rt_perf_rtng_flag 	    	    in  varchar2  default null
  ,p_rt_elig_prfl_flag 	    	    in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_vrbl_rt_prfl_id ben_vrbl_rt_prfl_f.vrbl_rt_prfl_id%TYPE;
  l_effective_start_date ben_vrbl_rt_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_prfl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_vrbl_rate_profile';
  l_object_version_number ben_vrbl_rt_prfl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

 hr_utility.set_location(' ins upr limit api ' || p_ultmt_upr_lmt,393);
 hr_utility.set_location(' ins lwr limit api ' || p_ultmt_lwr_lmt,393);

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_vrbl_rate_profile;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_vrbl_rate_profile
    --
    ben_vrbl_rate_profile_bk1.create_vrbl_rate_profile_b
      (p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_vrbl_rt_trtmt_cd               =>  p_vrbl_rt_trtmt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_incrmnt_elcn_val               =>  p_incrmnt_elcn_val
      ,p_dflt_elcn_val                  =>  p_dflt_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_ultmt_upr_lmt                  =>  p_ultmt_upr_lmt
      ,p_ultmt_lwr_lmt                  =>  p_ultmt_lwr_lmt
      ,p_ultmt_upr_lmt_calc_rl          =>  p_ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_calc_rl          =>  p_ultmt_lwr_lmt_calc_rl
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_val                            =>  p_val
      ,p_name                           =>  p_name
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_alwys_sum_all_cvg_flag         =>  p_alwys_sum_all_cvg_flag
      ,p_alwys_cnt_all_prtts_flag       =>  p_alwys_cnt_all_prtts_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_vrbl_rt_prfl_stat_cd           =>  p_vrbl_rt_prfl_stat_cd
      ,p_vrbl_usg_cd                    =>  p_vrbl_usg_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rt_hrly_slrd_flag              =>  p_rt_hrly_slrd_flag
      ,p_rt_pstl_cd_flag                =>  p_rt_pstl_cd_flag
      ,p_rt_lbr_mmbr_flag               =>  p_rt_lbr_mmbr_flag
      ,p_rt_lgl_enty_flag               =>  p_rt_lgl_enty_flag
      ,p_rt_benfts_grp_flag             =>  p_rt_benfts_grp_flag
      ,p_rt_wk_loc_flag                 =>  p_rt_wk_loc_flag
      ,p_rt_brgng_unit_flag             =>  p_rt_brgng_unit_flag
      ,p_rt_age_flag                    =>  p_rt_age_flag
      ,p_rt_los_flag                    =>  p_rt_los_flag
      ,p_rt_per_typ_flag                =>  p_rt_per_typ_flag
      ,p_rt_fl_tm_pt_tm_flag            =>  p_rt_fl_tm_pt_tm_flag
      ,p_rt_ee_stat_flag                =>  p_rt_ee_stat_flag
      ,p_rt_grd_flag                    =>  p_rt_grd_flag
      ,p_rt_pct_fl_tm_flag              =>  p_rt_pct_fl_tm_flag
      ,p_rt_asnt_set_flag               =>  p_rt_asnt_set_flag
      ,p_rt_hrs_wkd_flag                =>  p_rt_hrs_wkd_flag
      ,p_rt_comp_lvl_flag               =>  p_rt_comp_lvl_flag
      ,p_rt_org_unit_flag               =>  p_rt_org_unit_flag
      ,p_rt_loa_rsn_flag                =>  p_rt_loa_rsn_flag
      ,p_rt_pyrl_flag                   =>  p_rt_pyrl_flag
      ,p_rt_schedd_hrs_flag             =>  p_rt_schedd_hrs_flag
      ,p_rt_py_bss_flag                 =>  p_rt_py_bss_flag
      ,p_rt_prfl_rl_flag                =>  p_rt_prfl_rl_flag
      ,p_rt_cmbn_age_los_flag           =>  p_rt_cmbn_age_los_flag
      ,p_rt_prtt_pl_flag                =>  p_rt_prtt_pl_flag
      ,p_rt_svc_area_flag               =>  p_rt_svc_area_flag
      ,p_rt_ppl_grp_flag                =>  p_rt_ppl_grp_flag
      ,p_rt_dsbld_flag                  =>  p_rt_dsbld_flag
      ,p_rt_hlth_cvg_flag               =>  p_rt_hlth_cvg_flag
      ,p_rt_poe_flag                    =>  p_rt_poe_flag
      ,p_rt_ttl_cvg_vol_flag            =>  p_rt_ttl_cvg_vol_flag
      ,p_rt_ttl_prtt_flag               =>  p_rt_ttl_prtt_flag
      ,p_rt_gndr_flag                   =>  p_rt_gndr_flag
      ,p_rt_tbco_use_flag               =>  p_rt_tbco_use_flag
      ,p_vpf_attribute_category         =>  p_vpf_attribute_category
      ,p_vpf_attribute1                 =>  p_vpf_attribute1
      ,p_vpf_attribute2                 =>  p_vpf_attribute2
      ,p_vpf_attribute3                 =>  p_vpf_attribute3
      ,p_vpf_attribute4                 =>  p_vpf_attribute4
      ,p_vpf_attribute5                 =>  p_vpf_attribute5
      ,p_vpf_attribute6                 =>  p_vpf_attribute6
      ,p_vpf_attribute7                 =>  p_vpf_attribute7
      ,p_vpf_attribute8                 =>  p_vpf_attribute8
      ,p_vpf_attribute9                 =>  p_vpf_attribute9
      ,p_vpf_attribute10                =>  p_vpf_attribute10
      ,p_vpf_attribute11                =>  p_vpf_attribute11
      ,p_vpf_attribute12                =>  p_vpf_attribute12
      ,p_vpf_attribute13                =>  p_vpf_attribute13
      ,p_vpf_attribute14                =>  p_vpf_attribute14
      ,p_vpf_attribute15                =>  p_vpf_attribute15
      ,p_vpf_attribute16                =>  p_vpf_attribute16
      ,p_vpf_attribute17                =>  p_vpf_attribute17
      ,p_vpf_attribute18                =>  p_vpf_attribute18
      ,p_vpf_attribute19                =>  p_vpf_attribute19
      ,p_vpf_attribute20                =>  p_vpf_attribute20
      ,p_vpf_attribute21                =>  p_vpf_attribute21
      ,p_vpf_attribute22                =>  p_vpf_attribute22
      ,p_vpf_attribute23                =>  p_vpf_attribute23
      ,p_vpf_attribute24                =>  p_vpf_attribute24
      ,p_vpf_attribute25                =>  p_vpf_attribute25
      ,p_vpf_attribute26                =>  p_vpf_attribute26
      ,p_vpf_attribute27                =>  p_vpf_attribute27
      ,p_vpf_attribute28                =>  p_vpf_attribute28
      ,p_vpf_attribute29                =>  p_vpf_attribute29
      ,p_vpf_attribute30                =>  p_vpf_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_rt_cntng_prtn_prfl_flag	=>  p_rt_cntng_prtn_prfl_flag
      ,p_rt_cbr_quald_bnf_flag  	=>  p_rt_cbr_quald_bnf_flag
      ,p_rt_optd_mdcr_flag      	=>  p_rt_optd_mdcr_flag
      ,p_rt_lvg_rsn_flag        	=>  p_rt_lvg_rsn_flag
      ,p_rt_pstn_flag           	=>  p_rt_pstn_flag
      ,p_rt_comptncy_flag       	=>  p_rt_comptncy_flag
      ,p_rt_job_flag            	=>  p_rt_job_flag
      ,p_rt_qual_titl_flag      	=>  p_rt_qual_titl_flag
      ,p_rt_dpnt_cvrd_pl_flag   	=>  p_rt_dpnt_cvrd_pl_flag
      ,p_rt_dpnt_cvrd_plip_flag 	=>  p_rt_dpnt_cvrd_plip_flag
      ,p_rt_dpnt_cvrd_ptip_flag 	=>  p_rt_dpnt_cvrd_ptip_flag
      ,p_rt_dpnt_cvrd_pgm_flag  	=>  p_rt_dpnt_cvrd_pgm_flag
      ,p_rt_enrld_oipl_flag     	=>  p_rt_enrld_oipl_flag
      ,p_rt_enrld_pl_flag       	=>  p_rt_enrld_pl_flag
      ,p_rt_enrld_plip_flag     	=>  p_rt_enrld_plip_flag
      ,p_rt_enrld_ptip_flag     	=>  p_rt_enrld_ptip_flag
      ,p_rt_enrld_pgm_flag      	=>  p_rt_enrld_pgm_flag
      ,p_rt_prtt_anthr_pl_flag  	=>  p_rt_prtt_anthr_pl_flag
      ,p_rt_othr_ptip_flag      	=>  p_rt_othr_ptip_flag
      ,p_rt_no_othr_cvg_flag    	=>  p_rt_no_othr_cvg_flag
      ,p_rt_dpnt_othr_ptip_flag 	=>  p_rt_dpnt_othr_ptip_flag
      ,p_rt_qua_in_gr_flag    		=>  p_rt_qua_in_gr_flag
      ,p_rt_perf_rtng_flag 		=>  p_rt_perf_rtng_flag
      ,p_rt_elig_prfl_flag 		=>  p_rt_elig_prfl_flag);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_vrbl_rate_profile'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_vrbl_rate_profile
    --
  end;
  --
  ben_vpf_ins.ins
    (p_vrbl_rt_prfl_id               => l_vrbl_rt_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_typ_opt_typ_id             => p_pl_typ_opt_typ_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_business_group_id             => p_business_group_id
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_vrbl_rt_trtmt_cd              => p_vrbl_rt_trtmt_cd
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_mlt_cd                        => p_mlt_cd
    ,p_incrmnt_elcn_val              => p_incrmnt_elcn_val
    ,p_dflt_elcn_val                 => p_dflt_elcn_val
    ,p_mx_elcn_val                   => p_mx_elcn_val
    ,p_mn_elcn_val                   => p_mn_elcn_val
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_ultmt_upr_lmt                 => p_ultmt_upr_lmt
    ,p_ultmt_lwr_lmt                 => p_ultmt_lwr_lmt
    ,p_ultmt_upr_lmt_calc_rl         => p_ultmt_upr_lmt_calc_rl
    ,p_ultmt_lwr_lmt_calc_rl         => p_ultmt_lwr_lmt_calc_rl
    ,p_ann_mn_elcn_val               => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val               => p_ann_mx_elcn_val
    ,p_val                           => p_val
    ,p_name                          => p_name
    ,p_no_mn_elcn_val_dfnd_flag      => p_no_mn_elcn_val_dfnd_flag
    ,p_no_mx_elcn_val_dfnd_flag      => p_no_mx_elcn_val_dfnd_flag
    ,p_alwys_sum_all_cvg_flag        =>  p_alwys_sum_all_cvg_flag
    ,p_alwys_cnt_all_prtts_flag      =>  p_alwys_cnt_all_prtts_flag
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_vrbl_rt_prfl_stat_cd          => p_vrbl_rt_prfl_stat_cd
    ,p_vrbl_usg_cd                   => p_vrbl_usg_cd
    ,p_asmt_to_use_cd                => p_asmt_to_use_cd
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_rt_hrly_slrd_flag             => p_rt_hrly_slrd_flag
    ,p_rt_pstl_cd_flag               => p_rt_pstl_cd_flag
    ,p_rt_lbr_mmbr_flag              => p_rt_lbr_mmbr_flag
    ,p_rt_lgl_enty_flag              => p_rt_lgl_enty_flag
    ,p_rt_benfts_grp_flag            => p_rt_benfts_grp_flag
    ,p_rt_wk_loc_flag                => p_rt_wk_loc_flag
    ,p_rt_brgng_unit_flag            => p_rt_brgng_unit_flag
    ,p_rt_age_flag                   => p_rt_age_flag
    ,p_rt_los_flag                   => p_rt_los_flag
    ,p_rt_per_typ_flag               => p_rt_per_typ_flag
    ,p_rt_fl_tm_pt_tm_flag           => p_rt_fl_tm_pt_tm_flag
    ,p_rt_ee_stat_flag               => p_rt_ee_stat_flag
    ,p_rt_grd_flag                   => p_rt_grd_flag
    ,p_rt_pct_fl_tm_flag             => p_rt_pct_fl_tm_flag
    ,p_rt_asnt_set_flag              => p_rt_asnt_set_flag
    ,p_rt_hrs_wkd_flag               => p_rt_hrs_wkd_flag
    ,p_rt_comp_lvl_flag              => p_rt_comp_lvl_flag
    ,p_rt_org_unit_flag              => p_rt_org_unit_flag
    ,p_rt_loa_rsn_flag               => p_rt_loa_rsn_flag
    ,p_rt_pyrl_flag                  => p_rt_pyrl_flag
    ,p_rt_schedd_hrs_flag            => p_rt_schedd_hrs_flag
    ,p_rt_py_bss_flag                => p_rt_py_bss_flag
    ,p_rt_prfl_rl_flag               => p_rt_prfl_rl_flag
    ,p_rt_cmbn_age_los_flag          => p_rt_cmbn_age_los_flag
    ,p_rt_prtt_pl_flag               => p_rt_prtt_pl_flag
    ,p_rt_svc_area_flag              => p_rt_svc_area_flag
    ,p_rt_ppl_grp_flag               => p_rt_ppl_grp_flag
    ,p_rt_dsbld_flag                 => p_rt_dsbld_flag
    ,p_rt_hlth_cvg_flag              => p_rt_hlth_cvg_flag
    ,p_rt_poe_flag                   => p_rt_poe_flag
    ,p_rt_ttl_cvg_vol_flag           => p_rt_ttl_cvg_vol_flag
    ,p_rt_ttl_prtt_flag              => p_rt_ttl_prtt_flag
    ,p_rt_gndr_flag                  => p_rt_gndr_flag
    ,p_rt_tbco_use_flag              => p_rt_tbco_use_flag
    ,p_vpf_attribute_category        => p_vpf_attribute_category
    ,p_vpf_attribute1                => p_vpf_attribute1
    ,p_vpf_attribute2                => p_vpf_attribute2
    ,p_vpf_attribute3                => p_vpf_attribute3
    ,p_vpf_attribute4                => p_vpf_attribute4
    ,p_vpf_attribute5                => p_vpf_attribute5
    ,p_vpf_attribute6                => p_vpf_attribute6
    ,p_vpf_attribute7                => p_vpf_attribute7
    ,p_vpf_attribute8                => p_vpf_attribute8
    ,p_vpf_attribute9                => p_vpf_attribute9
    ,p_vpf_attribute10               => p_vpf_attribute10
    ,p_vpf_attribute11               => p_vpf_attribute11
    ,p_vpf_attribute12               => p_vpf_attribute12
    ,p_vpf_attribute13               => p_vpf_attribute13
    ,p_vpf_attribute14               => p_vpf_attribute14
    ,p_vpf_attribute15               => p_vpf_attribute15
    ,p_vpf_attribute16               => p_vpf_attribute16
    ,p_vpf_attribute17               => p_vpf_attribute17
    ,p_vpf_attribute18               => p_vpf_attribute18
    ,p_vpf_attribute19               => p_vpf_attribute19
    ,p_vpf_attribute20               => p_vpf_attribute20
    ,p_vpf_attribute21               => p_vpf_attribute21
    ,p_vpf_attribute22               => p_vpf_attribute22
    ,p_vpf_attribute23               => p_vpf_attribute23
    ,p_vpf_attribute24               => p_vpf_attribute24
    ,p_vpf_attribute25               => p_vpf_attribute25
    ,p_vpf_attribute26               => p_vpf_attribute26
    ,p_vpf_attribute27               => p_vpf_attribute27
    ,p_vpf_attribute28               => p_vpf_attribute28
    ,p_vpf_attribute29               => p_vpf_attribute29
    ,p_vpf_attribute30               => p_vpf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_rt_cntng_prtn_prfl_flag	     => p_rt_cntng_prtn_prfl_flag
    ,p_rt_cbr_quald_bnf_flag  	     => p_rt_cbr_quald_bnf_flag
    ,p_rt_optd_mdcr_flag      	     => p_rt_optd_mdcr_flag
    ,p_rt_lvg_rsn_flag        	     => p_rt_lvg_rsn_flag
    ,p_rt_pstn_flag           	     => p_rt_pstn_flag
    ,p_rt_comptncy_flag       	     => p_rt_comptncy_flag
    ,p_rt_job_flag            	     => p_rt_job_flag
    ,p_rt_qual_titl_flag      	     => p_rt_qual_titl_flag
    ,p_rt_dpnt_cvrd_pl_flag   	     => p_rt_dpnt_cvrd_pl_flag
    ,p_rt_dpnt_cvrd_plip_flag 	     => p_rt_dpnt_cvrd_plip_flag
    ,p_rt_dpnt_cvrd_ptip_flag 	     => p_rt_dpnt_cvrd_ptip_flag
    ,p_rt_dpnt_cvrd_pgm_flag  	     => p_rt_dpnt_cvrd_pgm_flag
    ,p_rt_enrld_oipl_flag     	     => p_rt_enrld_oipl_flag
    ,p_rt_enrld_pl_flag       	     => p_rt_enrld_pl_flag
    ,p_rt_enrld_plip_flag     	     => p_rt_enrld_plip_flag
    ,p_rt_enrld_ptip_flag     	     => p_rt_enrld_ptip_flag
    ,p_rt_enrld_pgm_flag      	     => p_rt_enrld_pgm_flag
    ,p_rt_prtt_anthr_pl_flag  	     => p_rt_prtt_anthr_pl_flag
    ,p_rt_othr_ptip_flag      	     => p_rt_othr_ptip_flag
    ,p_rt_no_othr_cvg_flag    	     => p_rt_no_othr_cvg_flag
    ,p_rt_dpnt_othr_ptip_flag 	     => p_rt_dpnt_othr_ptip_flag
    ,p_rt_qua_in_gr_flag    	     => p_rt_qua_in_gr_flag
    ,p_rt_perf_rtng_flag 	     => p_rt_perf_rtng_flag
    ,p_rt_elig_prfl_flag 	     => p_rt_elig_prfl_flag);
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_vrbl_rate_profile
    --
    ben_vrbl_rate_profile_bk1.create_vrbl_rate_profile_a
      (p_vrbl_rt_prfl_id                =>  l_vrbl_rt_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_vrbl_rt_trtmt_cd               =>  p_vrbl_rt_trtmt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_incrmnt_elcn_val               =>  p_incrmnt_elcn_val
      ,p_dflt_elcn_val                  =>  p_dflt_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ultmt_upr_lmt                  =>  p_ultmt_upr_lmt
      ,p_ultmt_lwr_lmt                  =>  p_ultmt_lwr_lmt
      ,p_ultmt_upr_lmt_calc_rl          =>  p_ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_calc_rl          =>  p_ultmt_lwr_lmt_calc_rl
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_val                            =>  p_val
      ,p_name                           =>  p_name
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_alwys_sum_all_cvg_flag         =>  p_alwys_sum_all_cvg_flag
      ,p_alwys_cnt_all_prtts_flag       =>  p_alwys_cnt_all_prtts_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_vrbl_rt_prfl_stat_cd           =>  p_vrbl_rt_prfl_stat_cd
      ,p_vrbl_usg_cd                    =>  p_vrbl_usg_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rt_hrly_slrd_flag              =>  p_rt_hrly_slrd_flag
      ,p_rt_pstl_cd_flag                =>  p_rt_pstl_cd_flag
      ,p_rt_lbr_mmbr_flag               =>  p_rt_lbr_mmbr_flag
      ,p_rt_lgl_enty_flag               =>  p_rt_lgl_enty_flag
      ,p_rt_benfts_grp_flag             =>  p_rt_benfts_grp_flag
      ,p_rt_wk_loc_flag                 =>  p_rt_wk_loc_flag
      ,p_rt_brgng_unit_flag             =>  p_rt_brgng_unit_flag
      ,p_rt_age_flag                    =>  p_rt_age_flag
      ,p_rt_los_flag                    =>  p_rt_los_flag
      ,p_rt_per_typ_flag                =>  p_rt_per_typ_flag
      ,p_rt_fl_tm_pt_tm_flag            =>  p_rt_fl_tm_pt_tm_flag
      ,p_rt_ee_stat_flag                =>  p_rt_ee_stat_flag
      ,p_rt_grd_flag                    =>  p_rt_grd_flag
      ,p_rt_pct_fl_tm_flag              =>  p_rt_pct_fl_tm_flag
      ,p_rt_asnt_set_flag               =>  p_rt_asnt_set_flag
      ,p_rt_hrs_wkd_flag                =>  p_rt_hrs_wkd_flag
      ,p_rt_comp_lvl_flag               =>  p_rt_comp_lvl_flag
      ,p_rt_org_unit_flag               =>  p_rt_org_unit_flag
      ,p_rt_loa_rsn_flag                =>  p_rt_loa_rsn_flag
      ,p_rt_pyrl_flag                   =>  p_rt_pyrl_flag
      ,p_rt_schedd_hrs_flag             =>  p_rt_schedd_hrs_flag
      ,p_rt_py_bss_flag                 =>  p_rt_py_bss_flag
      ,p_rt_prfl_rl_flag                =>  p_rt_prfl_rl_flag
      ,p_rt_cmbn_age_los_flag           =>  p_rt_cmbn_age_los_flag
      ,p_rt_prtt_pl_flag                =>  p_rt_prtt_pl_flag
      ,p_rt_svc_area_flag               =>  p_rt_svc_area_flag
      ,p_rt_ppl_grp_flag                =>  p_rt_ppl_grp_flag
      ,p_rt_dsbld_flag                  =>  p_rt_dsbld_flag
      ,p_rt_hlth_cvg_flag               =>  p_rt_hlth_cvg_flag
      ,p_rt_poe_flag                    =>  p_rt_poe_flag
      ,p_rt_ttl_cvg_vol_flag            =>  p_rt_ttl_cvg_vol_flag
      ,p_rt_ttl_prtt_flag               =>  p_rt_ttl_prtt_flag
      ,p_rt_gndr_flag                   =>  p_rt_gndr_flag
      ,p_rt_tbco_use_flag               =>  p_rt_tbco_use_flag
      ,p_vpf_attribute_category         =>  p_vpf_attribute_category
      ,p_vpf_attribute1                 =>  p_vpf_attribute1
      ,p_vpf_attribute2                 =>  p_vpf_attribute2
      ,p_vpf_attribute3                 =>  p_vpf_attribute3
      ,p_vpf_attribute4                 =>  p_vpf_attribute4
      ,p_vpf_attribute5                 =>  p_vpf_attribute5
      ,p_vpf_attribute6                 =>  p_vpf_attribute6
      ,p_vpf_attribute7                 =>  p_vpf_attribute7
      ,p_vpf_attribute8                 =>  p_vpf_attribute8
      ,p_vpf_attribute9                 =>  p_vpf_attribute9
      ,p_vpf_attribute10                =>  p_vpf_attribute10
      ,p_vpf_attribute11                =>  p_vpf_attribute11
      ,p_vpf_attribute12                =>  p_vpf_attribute12
      ,p_vpf_attribute13                =>  p_vpf_attribute13
      ,p_vpf_attribute14                =>  p_vpf_attribute14
      ,p_vpf_attribute15                =>  p_vpf_attribute15
      ,p_vpf_attribute16                =>  p_vpf_attribute16
      ,p_vpf_attribute17                =>  p_vpf_attribute17
      ,p_vpf_attribute18                =>  p_vpf_attribute18
      ,p_vpf_attribute19                =>  p_vpf_attribute19
      ,p_vpf_attribute20                =>  p_vpf_attribute20
      ,p_vpf_attribute21                =>  p_vpf_attribute21
      ,p_vpf_attribute22                =>  p_vpf_attribute22
      ,p_vpf_attribute23                =>  p_vpf_attribute23
      ,p_vpf_attribute24                =>  p_vpf_attribute24
      ,p_vpf_attribute25                =>  p_vpf_attribute25
      ,p_vpf_attribute26                =>  p_vpf_attribute26
      ,p_vpf_attribute27                =>  p_vpf_attribute27
      ,p_vpf_attribute28                =>  p_vpf_attribute28
      ,p_vpf_attribute29                =>  p_vpf_attribute29
      ,p_vpf_attribute30                =>  p_vpf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_rt_cntng_prtn_prfl_flag	=>  p_rt_cntng_prtn_prfl_flag
      ,p_rt_cbr_quald_bnf_flag  	=>  p_rt_cbr_quald_bnf_flag
      ,p_rt_optd_mdcr_flag      	=>  p_rt_optd_mdcr_flag
      ,p_rt_lvg_rsn_flag        	=>  p_rt_lvg_rsn_flag
      ,p_rt_pstn_flag           	=>  p_rt_pstn_flag
      ,p_rt_comptncy_flag       	=>  p_rt_comptncy_flag
      ,p_rt_job_flag            	=>  p_rt_job_flag
      ,p_rt_qual_titl_flag      	=>  p_rt_qual_titl_flag
      ,p_rt_dpnt_cvrd_pl_flag   	=>  p_rt_dpnt_cvrd_pl_flag
      ,p_rt_dpnt_cvrd_plip_flag 	=>  p_rt_dpnt_cvrd_plip_flag
      ,p_rt_dpnt_cvrd_ptip_flag 	=>  p_rt_dpnt_cvrd_ptip_flag
      ,p_rt_dpnt_cvrd_pgm_flag  	=>  p_rt_dpnt_cvrd_pgm_flag
      ,p_rt_enrld_oipl_flag     	=>  p_rt_enrld_oipl_flag
      ,p_rt_enrld_pl_flag       	=>  p_rt_enrld_pl_flag
      ,p_rt_enrld_plip_flag     	=>  p_rt_enrld_plip_flag
      ,p_rt_enrld_ptip_flag     	=>  p_rt_enrld_ptip_flag
      ,p_rt_enrld_pgm_flag      	=>  p_rt_enrld_pgm_flag
      ,p_rt_prtt_anthr_pl_flag  	=>  p_rt_prtt_anthr_pl_flag
      ,p_rt_othr_ptip_flag      	=>  p_rt_othr_ptip_flag
      ,p_rt_no_othr_cvg_flag    	=>  p_rt_no_othr_cvg_flag
      ,p_rt_dpnt_othr_ptip_flag 	=>  p_rt_dpnt_othr_ptip_flag
      ,p_rt_qua_in_gr_flag    		=>  p_rt_qua_in_gr_flag
      ,p_rt_perf_rtng_flag 		=>  p_rt_perf_rtng_flag
      ,p_rt_elig_prfl_flag 		=>  p_rt_elig_prfl_flag);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_vrbl_rate_profile'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_vrbl_rate_profile
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
  p_vrbl_rt_prfl_id := l_vrbl_rt_prfl_id;
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
    ROLLBACK TO create_vrbl_rate_profile;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vrbl_rt_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_vrbl_rate_profile;
    raise;
    --
end create_vrbl_rate_profile;
-- ----------------------------------------------------------------------------
-- |------------------------< update_vrbl_rate_profile >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vrbl_rate_profile
  (p_validate                       in  boolean   default false
  ,p_vrbl_rt_prfl_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_typ_opt_typ_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_vrbl_rt_trtmt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_mlt_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_incrmnt_elcn_val               in  number    default hr_api.g_number
  ,p_dflt_elcn_val                  in  number    default hr_api.g_number
  ,p_mx_elcn_val                    in  number    default hr_api.g_number
  ,p_mn_elcn_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_upr_lmt_val                    in  number    default hr_api.g_number
  ,p_upr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_ultmt_upr_lmt                  in  number    default hr_api.g_number
  ,p_ultmt_lwr_lmt                  in  number    default hr_api.g_number
  ,p_ultmt_upr_lmt_calc_rl          in  number    default hr_api.g_number
  ,p_ultmt_lwr_lmt_calc_rl          in  number    default hr_api.g_number
  ,p_ann_mn_elcn_val                in  number    default hr_api.g_number
  ,p_ann_mx_elcn_val                in  number    default hr_api.g_number
  ,p_val                            in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_elcn_val_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_elcn_val_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_alwys_sum_all_cvg_flag         in  varchar2  default hr_api.g_varchar2
  ,p_alwys_cnt_all_prtts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_val_calc_rl                    in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_stat_cd           in  varchar2  default hr_api.g_varchar2
  ,p_vrbl_usg_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_asmt_to_use_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_rt_hrly_slrd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_rt_pstl_cd_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_lbr_mmbr_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_lgl_enty_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_benfts_grp_flag             in  varchar2  default hr_api.g_varchar2
  ,p_rt_wk_loc_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_rt_brgng_unit_flag             in  varchar2  default hr_api.g_varchar2
  ,p_rt_age_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_rt_los_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_rt_per_typ_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_fl_tm_pt_tm_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_ee_stat_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_grd_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_rt_pct_fl_tm_flag              in  varchar2  default hr_api.g_varchar2
  ,p_rt_asnt_set_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_hrs_wkd_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_comp_lvl_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_org_unit_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_loa_rsn_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_pyrl_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_schedd_hrs_flag             in  varchar2  default hr_api.g_varchar2
  ,p_rt_py_bss_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_rt_prfl_rl_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_cmbn_age_los_flag           in  varchar2  default hr_api.g_varchar2
  ,p_rt_prtt_pl_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_svc_area_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_ppl_grp_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_dsbld_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_hlth_cvg_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_poe_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_rt_ttl_cvg_vol_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_ttl_prtt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_rt_gndr_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_tbco_use_flag               in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vpf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_rt_cntng_prtn_prfl_flag	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_cbr_quald_bnf_flag  	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_optd_mdcr_flag      	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_lvg_rsn_flag        	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_pstn_flag           	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_comptncy_flag       	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_job_flag            	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_qual_titl_flag      	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_dpnt_cvrd_pl_flag   	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_dpnt_cvrd_plip_flag 	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_dpnt_cvrd_ptip_flag 	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_dpnt_cvrd_pgm_flag  	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_enrld_oipl_flag     	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_enrld_pl_flag       	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_enrld_plip_flag     	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_enrld_ptip_flag     	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_enrld_pgm_flag      	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_prtt_anthr_pl_flag  	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_othr_ptip_flag      	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_no_othr_cvg_flag    	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_dpnt_othr_ptip_flag 	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_qua_in_gr_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_rt_perf_rtng_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_rt_elig_prfl_flag		    in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_vrbl_rate_profile';
  l_object_version_number ben_vrbl_rt_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_vrbl_rt_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_prfl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);


 hr_utility.set_location(' upd upr limit api ' || p_ultmt_upr_lmt_calc_rl,393);
 hr_utility.set_location(' upd lwr limit api ' || p_ultmt_lwr_lmt_calc_rl,393);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_vrbl_rate_profile;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_vrbl_rate_profile
    --
    ben_vrbl_rate_profile_bk2.update_vrbl_rate_profile_b
      (p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_vrbl_rt_trtmt_cd               =>  p_vrbl_rt_trtmt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_incrmnt_elcn_val               =>  p_incrmnt_elcn_val
      ,p_dflt_elcn_val                  =>  p_dflt_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ultmt_upr_lmt                  =>  p_ultmt_upr_lmt
      ,p_ultmt_lwr_lmt                  =>  p_ultmt_lwr_lmt
      ,p_ultmt_upr_lmt_calc_rl          =>  p_ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_calc_rl          =>  p_ultmt_lwr_lmt_calc_rl
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_val                            =>  p_val
      ,p_name                           =>  p_name
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_alwys_sum_all_cvg_flag         =>  p_alwys_sum_all_cvg_flag
      ,p_alwys_cnt_all_prtts_flag       =>  p_alwys_cnt_all_prtts_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_vrbl_rt_prfl_stat_cd           =>  p_vrbl_rt_prfl_stat_cd
      ,p_vrbl_usg_cd                    =>  p_vrbl_usg_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rt_hrly_slrd_flag              =>  p_rt_hrly_slrd_flag
      ,p_rt_pstl_cd_flag                =>  p_rt_pstl_cd_flag
      ,p_rt_lbr_mmbr_flag               =>  p_rt_lbr_mmbr_flag
      ,p_rt_lgl_enty_flag               =>  p_rt_lgl_enty_flag
      ,p_rt_benfts_grp_flag             =>  p_rt_benfts_grp_flag
      ,p_rt_wk_loc_flag                 =>  p_rt_wk_loc_flag
      ,p_rt_brgng_unit_flag             =>  p_rt_brgng_unit_flag
      ,p_rt_age_flag                    =>  p_rt_age_flag
      ,p_rt_los_flag                    =>  p_rt_los_flag
      ,p_rt_per_typ_flag                =>  p_rt_per_typ_flag
      ,p_rt_fl_tm_pt_tm_flag            =>  p_rt_fl_tm_pt_tm_flag
      ,p_rt_ee_stat_flag                =>  p_rt_ee_stat_flag
      ,p_rt_grd_flag                    =>  p_rt_grd_flag
      ,p_rt_pct_fl_tm_flag              =>  p_rt_pct_fl_tm_flag
      ,p_rt_asnt_set_flag               =>  p_rt_asnt_set_flag
      ,p_rt_hrs_wkd_flag                =>  p_rt_hrs_wkd_flag
      ,p_rt_comp_lvl_flag               =>  p_rt_comp_lvl_flag
      ,p_rt_org_unit_flag               =>  p_rt_org_unit_flag
      ,p_rt_loa_rsn_flag                =>  p_rt_loa_rsn_flag
      ,p_rt_pyrl_flag                   =>  p_rt_pyrl_flag
      ,p_rt_schedd_hrs_flag             =>  p_rt_schedd_hrs_flag
      ,p_rt_py_bss_flag                 =>  p_rt_py_bss_flag
      ,p_rt_prfl_rl_flag                =>  p_rt_prfl_rl_flag
      ,p_rt_cmbn_age_los_flag           =>  p_rt_cmbn_age_los_flag
      ,p_rt_prtt_pl_flag                =>  p_rt_prtt_pl_flag
      ,p_rt_svc_area_flag               =>  p_rt_svc_area_flag
      ,p_rt_ppl_grp_flag                =>  p_rt_ppl_grp_flag
      ,p_rt_dsbld_flag                  =>  p_rt_dsbld_flag
      ,p_rt_hlth_cvg_flag               =>  p_rt_hlth_cvg_flag
      ,p_rt_poe_flag                    =>  p_rt_poe_flag
      ,p_rt_ttl_cvg_vol_flag            =>  p_rt_ttl_cvg_vol_flag
      ,p_rt_ttl_prtt_flag               =>  p_rt_ttl_prtt_flag
      ,p_rt_gndr_flag                   =>  p_rt_gndr_flag
      ,p_rt_tbco_use_flag               =>  p_rt_tbco_use_flag
      ,p_vpf_attribute_category         =>  p_vpf_attribute_category
      ,p_vpf_attribute1                 =>  p_vpf_attribute1
      ,p_vpf_attribute2                 =>  p_vpf_attribute2
      ,p_vpf_attribute3                 =>  p_vpf_attribute3
      ,p_vpf_attribute4                 =>  p_vpf_attribute4
      ,p_vpf_attribute5                 =>  p_vpf_attribute5
      ,p_vpf_attribute6                 =>  p_vpf_attribute6
      ,p_vpf_attribute7                 =>  p_vpf_attribute7
      ,p_vpf_attribute8                 =>  p_vpf_attribute8
      ,p_vpf_attribute9                 =>  p_vpf_attribute9
      ,p_vpf_attribute10                =>  p_vpf_attribute10
      ,p_vpf_attribute11                =>  p_vpf_attribute11
      ,p_vpf_attribute12                =>  p_vpf_attribute12
      ,p_vpf_attribute13                =>  p_vpf_attribute13
      ,p_vpf_attribute14                =>  p_vpf_attribute14
      ,p_vpf_attribute15                =>  p_vpf_attribute15
      ,p_vpf_attribute16                =>  p_vpf_attribute16
      ,p_vpf_attribute17                =>  p_vpf_attribute17
      ,p_vpf_attribute18                =>  p_vpf_attribute18
      ,p_vpf_attribute19                =>  p_vpf_attribute19
      ,p_vpf_attribute20                =>  p_vpf_attribute20
      ,p_vpf_attribute21                =>  p_vpf_attribute21
      ,p_vpf_attribute22                =>  p_vpf_attribute22
      ,p_vpf_attribute23                =>  p_vpf_attribute23
      ,p_vpf_attribute24                =>  p_vpf_attribute24
      ,p_vpf_attribute25                =>  p_vpf_attribute25
      ,p_vpf_attribute26                =>  p_vpf_attribute26
      ,p_vpf_attribute27                =>  p_vpf_attribute27
      ,p_vpf_attribute28                =>  p_vpf_attribute28
      ,p_vpf_attribute29                =>  p_vpf_attribute29
      ,p_vpf_attribute30                =>  p_vpf_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_rt_cntng_prtn_prfl_flag	=>  p_rt_cntng_prtn_prfl_flag
      ,p_rt_cbr_quald_bnf_flag  	=>  p_rt_cbr_quald_bnf_flag
      ,p_rt_optd_mdcr_flag      	=>  p_rt_optd_mdcr_flag
      ,p_rt_lvg_rsn_flag        	=>  p_rt_lvg_rsn_flag
      ,p_rt_pstn_flag           	=>  p_rt_pstn_flag
      ,p_rt_comptncy_flag       	=>  p_rt_comptncy_flag
      ,p_rt_job_flag            	=>  p_rt_job_flag
      ,p_rt_qual_titl_flag      	=>  p_rt_qual_titl_flag
      ,p_rt_dpnt_cvrd_pl_flag   	=>  p_rt_dpnt_cvrd_pl_flag
      ,p_rt_dpnt_cvrd_plip_flag 	=>  p_rt_dpnt_cvrd_plip_flag
      ,p_rt_dpnt_cvrd_ptip_flag 	=>  p_rt_dpnt_cvrd_ptip_flag
      ,p_rt_dpnt_cvrd_pgm_flag  	=>  p_rt_dpnt_cvrd_pgm_flag
      ,p_rt_enrld_oipl_flag     	=>  p_rt_enrld_oipl_flag
      ,p_rt_enrld_pl_flag       	=>  p_rt_enrld_pl_flag
      ,p_rt_enrld_plip_flag     	=>  p_rt_enrld_plip_flag
      ,p_rt_enrld_ptip_flag     	=>  p_rt_enrld_ptip_flag
      ,p_rt_enrld_pgm_flag      	=>  p_rt_enrld_pgm_flag
      ,p_rt_prtt_anthr_pl_flag  	=>  p_rt_prtt_anthr_pl_flag
      ,p_rt_othr_ptip_flag      	=>  p_rt_othr_ptip_flag
      ,p_rt_no_othr_cvg_flag    	=>  p_rt_no_othr_cvg_flag
      ,p_rt_dpnt_othr_ptip_flag 	=>  p_rt_dpnt_othr_ptip_flag
      ,p_rt_qua_in_gr_flag              =>  p_rt_qua_in_gr_flag
      ,p_rt_perf_rtng_flag	    	=>  p_rt_perf_rtng_flag
      ,p_rt_elig_prfl_flag	    	=>  p_rt_elig_prfl_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_vrbl_rate_profile'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_vrbl_rate_profile
    --
  end;
  --
  ben_vpf_upd.upd
    (p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_typ_opt_typ_id             => p_pl_typ_opt_typ_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_business_group_id             => p_business_group_id
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_vrbl_rt_trtmt_cd              => p_vrbl_rt_trtmt_cd
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_mlt_cd                        => p_mlt_cd
    ,p_incrmnt_elcn_val              => p_incrmnt_elcn_val
    ,p_dflt_elcn_val                 => p_dflt_elcn_val
    ,p_mx_elcn_val                   => p_mx_elcn_val
    ,p_mn_elcn_val                   => p_mn_elcn_val
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_ultmt_upr_lmt                 => p_ultmt_upr_lmt
    ,p_ultmt_lwr_lmt                 => p_ultmt_lwr_lmt
    ,p_ultmt_upr_lmt_calc_rl         => p_ultmt_upr_lmt_calc_rl
    ,p_ultmt_lwr_lmt_calc_rl         => p_ultmt_lwr_lmt_calc_rl
    ,p_ann_mn_elcn_val               => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val               => p_ann_mx_elcn_val
    ,p_val                           => p_val
    ,p_name                          => p_name
    ,p_no_mn_elcn_val_dfnd_flag      => p_no_mn_elcn_val_dfnd_flag
    ,p_no_mx_elcn_val_dfnd_flag      => p_no_mx_elcn_val_dfnd_flag
    ,p_alwys_sum_all_cvg_flag        => p_alwys_sum_all_cvg_flag
    ,p_alwys_cnt_all_prtts_flag      => p_alwys_cnt_all_prtts_flag
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_vrbl_rt_prfl_stat_cd          => p_vrbl_rt_prfl_stat_cd
    ,p_vrbl_usg_cd                   => p_vrbl_usg_cd
    ,p_asmt_to_use_cd                => p_asmt_to_use_cd
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_rt_hrly_slrd_flag             => p_rt_hrly_slrd_flag
    ,p_rt_pstl_cd_flag               => p_rt_pstl_cd_flag
    ,p_rt_lbr_mmbr_flag              => p_rt_lbr_mmbr_flag
    ,p_rt_lgl_enty_flag              => p_rt_lgl_enty_flag
    ,p_rt_benfts_grp_flag            => p_rt_benfts_grp_flag
    ,p_rt_wk_loc_flag                => p_rt_wk_loc_flag
    ,p_rt_brgng_unit_flag            => p_rt_brgng_unit_flag
    ,p_rt_age_flag                   => p_rt_age_flag
    ,p_rt_los_flag                   => p_rt_los_flag
    ,p_rt_per_typ_flag               => p_rt_per_typ_flag
    ,p_rt_fl_tm_pt_tm_flag           => p_rt_fl_tm_pt_tm_flag
    ,p_rt_ee_stat_flag               => p_rt_ee_stat_flag
    ,p_rt_grd_flag                   => p_rt_grd_flag
    ,p_rt_pct_fl_tm_flag             => p_rt_pct_fl_tm_flag
    ,p_rt_asnt_set_flag              => p_rt_asnt_set_flag
    ,p_rt_hrs_wkd_flag               => p_rt_hrs_wkd_flag
    ,p_rt_comp_lvl_flag              => p_rt_comp_lvl_flag
    ,p_rt_org_unit_flag              => p_rt_org_unit_flag
    ,p_rt_loa_rsn_flag               => p_rt_loa_rsn_flag
    ,p_rt_pyrl_flag                  => p_rt_pyrl_flag
    ,p_rt_schedd_hrs_flag            => p_rt_schedd_hrs_flag
    ,p_rt_py_bss_flag                => p_rt_py_bss_flag
    ,p_rt_prfl_rl_flag               => p_rt_prfl_rl_flag
    ,p_rt_cmbn_age_los_flag          => p_rt_cmbn_age_los_flag
    ,p_rt_prtt_pl_flag               => p_rt_prtt_pl_flag
    ,p_rt_svc_area_flag              => p_rt_svc_area_flag
    ,p_rt_ppl_grp_flag               => p_rt_ppl_grp_flag
    ,p_rt_dsbld_flag                 => p_rt_dsbld_flag
    ,p_rt_hlth_cvg_flag              => p_rt_hlth_cvg_flag
    ,p_rt_poe_flag                   => p_rt_poe_flag
    ,p_rt_ttl_cvg_vol_flag           => p_rt_ttl_cvg_vol_flag
    ,p_rt_ttl_prtt_flag              => p_rt_ttl_prtt_flag
    ,p_rt_gndr_flag                  => p_rt_gndr_flag
    ,p_rt_tbco_use_flag              => p_rt_tbco_use_flag
    ,p_vpf_attribute_category        => p_vpf_attribute_category
    ,p_vpf_attribute1                => p_vpf_attribute1
    ,p_vpf_attribute2                => p_vpf_attribute2
    ,p_vpf_attribute3                => p_vpf_attribute3
    ,p_vpf_attribute4                => p_vpf_attribute4
    ,p_vpf_attribute5                => p_vpf_attribute5
    ,p_vpf_attribute6                => p_vpf_attribute6
    ,p_vpf_attribute7                => p_vpf_attribute7
    ,p_vpf_attribute8                => p_vpf_attribute8
    ,p_vpf_attribute9                => p_vpf_attribute9
    ,p_vpf_attribute10               => p_vpf_attribute10
    ,p_vpf_attribute11               => p_vpf_attribute11
    ,p_vpf_attribute12               => p_vpf_attribute12
    ,p_vpf_attribute13               => p_vpf_attribute13
    ,p_vpf_attribute14               => p_vpf_attribute14
    ,p_vpf_attribute15               => p_vpf_attribute15
    ,p_vpf_attribute16               => p_vpf_attribute16
    ,p_vpf_attribute17               => p_vpf_attribute17
    ,p_vpf_attribute18               => p_vpf_attribute18
    ,p_vpf_attribute19               => p_vpf_attribute19
    ,p_vpf_attribute20               => p_vpf_attribute20
    ,p_vpf_attribute21               => p_vpf_attribute21
    ,p_vpf_attribute22               => p_vpf_attribute22
    ,p_vpf_attribute23               => p_vpf_attribute23
    ,p_vpf_attribute24               => p_vpf_attribute24
    ,p_vpf_attribute25               => p_vpf_attribute25
    ,p_vpf_attribute26               => p_vpf_attribute26
    ,p_vpf_attribute27               => p_vpf_attribute27
    ,p_vpf_attribute28               => p_vpf_attribute28
    ,p_vpf_attribute29               => p_vpf_attribute29
    ,p_vpf_attribute30               => p_vpf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_rt_cntng_prtn_prfl_flag       => p_rt_cntng_prtn_prfl_flag
    ,p_rt_cbr_quald_bnf_flag         => p_rt_cbr_quald_bnf_flag
    ,p_rt_optd_mdcr_flag             => p_rt_optd_mdcr_flag
    ,p_rt_lvg_rsn_flag               => p_rt_lvg_rsn_flag
    ,p_rt_pstn_flag                  => p_rt_pstn_flag
    ,p_rt_comptncy_flag              => p_rt_comptncy_flag
    ,p_rt_job_flag                   => p_rt_job_flag
    ,p_rt_qual_titl_flag             => p_rt_qual_titl_flag
    ,p_rt_dpnt_cvrd_pl_flag          => p_rt_dpnt_cvrd_pl_flag
    ,p_rt_dpnt_cvrd_plip_flag        => p_rt_dpnt_cvrd_plip_flag
    ,p_rt_dpnt_cvrd_ptip_flag        => p_rt_dpnt_cvrd_ptip_flag
    ,p_rt_dpnt_cvrd_pgm_flag         => p_rt_dpnt_cvrd_pgm_flag
    ,p_rt_enrld_oipl_flag            => p_rt_enrld_oipl_flag
    ,p_rt_enrld_pl_flag              => p_rt_enrld_pl_flag
    ,p_rt_enrld_plip_flag            => p_rt_enrld_plip_flag
    ,p_rt_enrld_ptip_flag            => p_rt_enrld_ptip_flag
    ,p_rt_enrld_pgm_flag             => p_rt_enrld_pgm_flag
    ,p_rt_prtt_anthr_pl_flag         => p_rt_prtt_anthr_pl_flag
    ,p_rt_othr_ptip_flag             => p_rt_othr_ptip_flag
    ,p_rt_no_othr_cvg_flag           => p_rt_no_othr_cvg_flag
    ,p_rt_dpnt_othr_ptip_flag        => p_rt_dpnt_othr_ptip_flag
    ,p_rt_qua_in_gr_flag    	     => p_rt_qua_in_gr_flag
    ,p_rt_perf_rtng_flag 	     => p_rt_perf_rtng_flag
    ,p_rt_elig_prfl_flag 	     => p_rt_elig_prfl_flag);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_vrbl_rate_profile
    --
    ben_vrbl_rate_profile_bk2.update_vrbl_rate_profile_a
      (p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_vrbl_rt_trtmt_cd               =>  p_vrbl_rt_trtmt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_incrmnt_elcn_val               =>  p_incrmnt_elcn_val
      ,p_dflt_elcn_val                  =>  p_dflt_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_ultmt_upr_lmt                  =>  p_ultmt_upr_lmt
      ,p_ultmt_lwr_lmt                  =>  p_ultmt_lwr_lmt
      ,p_ultmt_upr_lmt_calc_rl          =>  p_ultmt_upr_lmt_calc_rl
      ,p_ultmt_lwr_lmt_calc_rl          =>  p_ultmt_lwr_lmt_calc_rl
      ,p_ann_mn_elcn_val                =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val                =>  p_ann_mx_elcn_val
      ,p_val                            =>  p_val
      ,p_name                           =>  p_name
      ,p_no_mn_elcn_val_dfnd_flag       =>  p_no_mn_elcn_val_dfnd_flag
      ,p_no_mx_elcn_val_dfnd_flag       =>  p_no_mx_elcn_val_dfnd_flag
      ,p_alwys_sum_all_cvg_flag         =>  p_alwys_sum_all_cvg_flag
      ,p_alwys_cnt_all_prtts_flag       =>  p_alwys_cnt_all_prtts_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_vrbl_rt_prfl_stat_cd           =>  p_vrbl_rt_prfl_stat_cd
      ,p_vrbl_usg_cd                    =>  p_vrbl_usg_cd
      ,p_asmt_to_use_cd                 =>  p_asmt_to_use_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rt_hrly_slrd_flag              =>  p_rt_hrly_slrd_flag
      ,p_rt_pstl_cd_flag                =>  p_rt_pstl_cd_flag
      ,p_rt_lbr_mmbr_flag               =>  p_rt_lbr_mmbr_flag
      ,p_rt_lgl_enty_flag               =>  p_rt_lgl_enty_flag
      ,p_rt_benfts_grp_flag             =>  p_rt_benfts_grp_flag
      ,p_rt_wk_loc_flag                 =>  p_rt_wk_loc_flag
      ,p_rt_brgng_unit_flag             =>  p_rt_brgng_unit_flag
      ,p_rt_age_flag                    =>  p_rt_age_flag
      ,p_rt_los_flag                    =>  p_rt_los_flag
      ,p_rt_per_typ_flag                =>  p_rt_per_typ_flag
      ,p_rt_fl_tm_pt_tm_flag            =>  p_rt_fl_tm_pt_tm_flag
      ,p_rt_ee_stat_flag                =>  p_rt_ee_stat_flag
      ,p_rt_grd_flag                    =>  p_rt_grd_flag
      ,p_rt_pct_fl_tm_flag              =>  p_rt_pct_fl_tm_flag
      ,p_rt_asnt_set_flag               =>  p_rt_asnt_set_flag
      ,p_rt_hrs_wkd_flag                =>  p_rt_hrs_wkd_flag
      ,p_rt_comp_lvl_flag               =>  p_rt_comp_lvl_flag
      ,p_rt_org_unit_flag               =>  p_rt_org_unit_flag
      ,p_rt_loa_rsn_flag                =>  p_rt_loa_rsn_flag
      ,p_rt_pyrl_flag                   =>  p_rt_pyrl_flag
      ,p_rt_schedd_hrs_flag             =>  p_rt_schedd_hrs_flag
      ,p_rt_py_bss_flag                 =>  p_rt_py_bss_flag
      ,p_rt_prfl_rl_flag                =>  p_rt_prfl_rl_flag
      ,p_rt_cmbn_age_los_flag           =>  p_rt_cmbn_age_los_flag
      ,p_rt_prtt_pl_flag                =>  p_rt_prtt_pl_flag
      ,p_rt_svc_area_flag               =>  p_rt_svc_area_flag
      ,p_rt_ppl_grp_flag                =>  p_rt_ppl_grp_flag
      ,p_rt_dsbld_flag                  =>  p_rt_dsbld_flag
      ,p_rt_hlth_cvg_flag               =>  p_rt_hlth_cvg_flag
      ,p_rt_poe_flag                    =>  p_rt_poe_flag
      ,p_rt_ttl_cvg_vol_flag            =>  p_rt_ttl_cvg_vol_flag
      ,p_rt_ttl_prtt_flag               =>  p_rt_ttl_prtt_flag
      ,p_rt_gndr_flag                   =>  p_rt_gndr_flag
      ,p_rt_tbco_use_flag               =>  p_rt_tbco_use_flag
      ,p_vpf_attribute_category         =>  p_vpf_attribute_category
      ,p_vpf_attribute1                 =>  p_vpf_attribute1
      ,p_vpf_attribute2                 =>  p_vpf_attribute2
      ,p_vpf_attribute3                 =>  p_vpf_attribute3
      ,p_vpf_attribute4                 =>  p_vpf_attribute4
      ,p_vpf_attribute5                 =>  p_vpf_attribute5
      ,p_vpf_attribute6                 =>  p_vpf_attribute6
      ,p_vpf_attribute7                 =>  p_vpf_attribute7
      ,p_vpf_attribute8                 =>  p_vpf_attribute8
      ,p_vpf_attribute9                 =>  p_vpf_attribute9
      ,p_vpf_attribute10                =>  p_vpf_attribute10
      ,p_vpf_attribute11                =>  p_vpf_attribute11
      ,p_vpf_attribute12                =>  p_vpf_attribute12
      ,p_vpf_attribute13                =>  p_vpf_attribute13
      ,p_vpf_attribute14                =>  p_vpf_attribute14
      ,p_vpf_attribute15                =>  p_vpf_attribute15
      ,p_vpf_attribute16                =>  p_vpf_attribute16
      ,p_vpf_attribute17                =>  p_vpf_attribute17
      ,p_vpf_attribute18                =>  p_vpf_attribute18
      ,p_vpf_attribute19                =>  p_vpf_attribute19
      ,p_vpf_attribute20                =>  p_vpf_attribute20
      ,p_vpf_attribute21                =>  p_vpf_attribute21
      ,p_vpf_attribute22                =>  p_vpf_attribute22
      ,p_vpf_attribute23                =>  p_vpf_attribute23
      ,p_vpf_attribute24                =>  p_vpf_attribute24
      ,p_vpf_attribute25                =>  p_vpf_attribute25
      ,p_vpf_attribute26                =>  p_vpf_attribute26
      ,p_vpf_attribute27                =>  p_vpf_attribute27
      ,p_vpf_attribute28                =>  p_vpf_attribute28
      ,p_vpf_attribute29                =>  p_vpf_attribute29
      ,p_vpf_attribute30                =>  p_vpf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_rt_cntng_prtn_prfl_flag        =>  p_rt_cntng_prtn_prfl_flag
      ,p_rt_cbr_quald_bnf_flag          =>  p_rt_cbr_quald_bnf_flag
      ,p_rt_optd_mdcr_flag              =>  p_rt_optd_mdcr_flag
      ,p_rt_lvg_rsn_flag                =>  p_rt_lvg_rsn_flag
      ,p_rt_pstn_flag                   =>  p_rt_pstn_flag
      ,p_rt_comptncy_flag               =>  p_rt_comptncy_flag
      ,p_rt_job_flag                    =>  p_rt_job_flag
      ,p_rt_qual_titl_flag              =>  p_rt_qual_titl_flag
      ,p_rt_dpnt_cvrd_pl_flag           =>  p_rt_dpnt_cvrd_pl_flag
      ,p_rt_dpnt_cvrd_plip_flag         =>  p_rt_dpnt_cvrd_plip_flag
      ,p_rt_dpnt_cvrd_ptip_flag         =>  p_rt_dpnt_cvrd_ptip_flag
      ,p_rt_dpnt_cvrd_pgm_flag          =>  p_rt_dpnt_cvrd_pgm_flag
      ,p_rt_enrld_oipl_flag             =>  p_rt_enrld_oipl_flag
      ,p_rt_enrld_pl_flag               =>  p_rt_enrld_pl_flag
      ,p_rt_enrld_plip_flag             =>  p_rt_enrld_plip_flag
      ,p_rt_enrld_ptip_flag             =>  p_rt_enrld_ptip_flag
      ,p_rt_enrld_pgm_flag              =>  p_rt_enrld_pgm_flag
      ,p_rt_prtt_anthr_pl_flag          =>  p_rt_prtt_anthr_pl_flag
      ,p_rt_othr_ptip_flag              =>  p_rt_othr_ptip_flag
      ,p_rt_no_othr_cvg_flag            =>  p_rt_no_othr_cvg_flag
      ,p_rt_dpnt_othr_ptip_flag         =>  p_rt_dpnt_othr_ptip_flag
      ,p_rt_qua_in_gr_flag    	        =>  p_rt_qua_in_gr_flag
      ,p_rt_perf_rtng_flag 		=>  p_rt_perf_rtng_flag
      ,p_rt_elig_prfl_flag 		=>  p_rt_elig_prfl_flag);
      --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_vrbl_rate_profile'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_vrbl_rate_profile
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
    ROLLBACK TO update_vrbl_rate_profile;
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
    ROLLBACK TO update_vrbl_rate_profile;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_vrbl_rate_profile;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_vrbl_rate_profile >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vrbl_rate_profile
  (p_validate                       in  boolean  default false
  ,p_vrbl_rt_prfl_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_vrbl_rate_profile';
  l_object_version_number ben_vrbl_rt_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_vrbl_rt_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_vrbl_rt_prfl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_vrbl_rate_profile;
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
    -- Start of API User Hook for the before hook of delete_vrbl_rate_profile
    --
    ben_vrbl_rate_profile_bk3.delete_vrbl_rate_profile_b
      (p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_vrbl_rate_profile'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_vrbl_rate_profile
    --
  end;
  --
  ben_vpf_del.del
    (p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_vrbl_rate_profile
    --
    ben_vrbl_rate_profile_bk3.delete_vrbl_rate_profile_a
      (p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_vrbl_rate_profile'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_vrbl_rate_profile
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
    ROLLBACK TO delete_vrbl_rate_profile;
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
    ROLLBACK TO delete_vrbl_rate_profile;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_vrbl_rate_profile;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_vrbl_rt_prfl_id                in     number
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
  ben_vpf_shd.lck
    ( p_vrbl_rt_prfl_id            => p_vrbl_rt_prfl_id
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
end ben_vrbl_rate_profile_api;

/
