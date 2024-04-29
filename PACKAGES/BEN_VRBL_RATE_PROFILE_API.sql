--------------------------------------------------------
--  DDL for Package BEN_VRBL_RATE_PROFILE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_RATE_PROFILE_API" AUTHID CURRENT_USER as
/* $Header: bevpfapi.pkh 120.0 2005/05/28 12:08:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_vrbl_rate_profile >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_pl_typ_opt_typ_id            No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_comp_lvl_fctr_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_acty_typ_cd                  Yes  varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_tx_typ_cd                    Yes  varchar2
--   p_vrbl_rt_trtmt_cd             Yes  varchar2
--   p_acty_ref_perd_cd             Yes  varchar2
--   p_mlt_cd                       Yes  varchar2
--   p_incrmnt_elcn_val             No   number
--   p_dflt_elcn_val                No   number
--   p_mx_elcn_val                  No   number
--   p_mn_elcn_val                  No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_ultmt_upr_lmt                No   number
--   p_ultmt_lwr_lmt                No   number
--   p_ultmt_upr_lmt_calc_rl        No   number
--   p_ultmt_lwr_lmt_calc_rl        No   number
--   p_ann_mn_elcn_val              No   number
--   p_ann_mx_elcn_val              No   number
--   p_val                          No   number
--   p_name                         Yes  varchar2
--   p_no_mn_elcn_val_dfnd_flag     Yes  varchar2
--   p_no_mx_elcn_val_dfnd_flag     Yes  varchar2
--   p_alwys_sum_all_cvg_flag       Yes  varchar2
--   p_alwys_cnt_all_prtts_flag     Yes  varchar2
--   p_val_calc_rl                  No   number
--   p_vrbl_rt_prfl_stat_cd         No   varchar2
--   p_vrbl_usg_cd                  No   varchar2
--   p_asmt_to_use_cd               No   varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_vpf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vpf_attribute1               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute2               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute3               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute4               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute5               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute6               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute7               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute8               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute9               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute10              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute11              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute12              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute13              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute14              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute15              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute16              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute17              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute18              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute19              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute20              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute21              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute22              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute23              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute24              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute25              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute26              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute27              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute28              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute29              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_vrbl_rt_prfl_id              Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_vrbl_rate_profile
(  p_validate                       in boolean    default false
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
  ,p_rt_qua_in_gr_flag    	    in  varchar2  default null
  ,p_rt_perf_rtng_flag    	    in  varchar2  default null
  ,p_rt_elig_prfl_flag    	    in  varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_vrbl_rate_profile >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_vrbl_rt_prfl_id              Yes  number    PK of record
--   p_pl_typ_opt_typ_id            No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_comp_lvl_fctr_id             No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_acty_typ_cd                  Yes  varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_tx_typ_cd                    Yes  varchar2
--   p_vrbl_rt_trtmt_cd             Yes  varchar2
--   p_acty_ref_perd_cd             Yes  varchar2
--   p_mlt_cd                       Yes  varchar2
--   p_incrmnt_elcn_val             No   number
--   p_dflt_elcn_val                No   number
--   p_mx_elcn_val                  No   number
--   p_mn_elcn_val                  No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_ultmt_upr_lmt                No   number
--   p_ultmt_lwr_lmt                No   number
--   p_ultmt_upr_lmt_calc_rl        No   number
--   p_ultmt_lwr_lmt_calc_rl        No   number
--   p_ann_mn_elcn_val              No   number
--   p_ann_mx_elcn_val              No   number
--   p_val                          No   number
--   p_name                         Yes  varchar2
--   p_no_mn_elcn_val_dfnd_flag     Yes  varchar2
--   p_no_mx_elcn_val_dfnd_flag     Yes  varchar2
--   p_alwys_sum_all_cvg_flag       Yes  varchar2
--   p_alwys_cnt_all_prtts_flag     Yes  varchar2
--   p_val_calc_rl                  No   number
--   p_vrbl_rt_prfl_stat_cd         No   varchar2
--   p_vrbl_usg_cd                  No   varchar2
--   p_asmt_to_use_cd               No   varchar2
--   p_rndg_cd                      No   varchar2
--   p_rndg_rl                      No   number
--   p_vpf_attribute_category       No   varchar2  Descriptive Flexfield
--   p_vpf_attribute1               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute2               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute3               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute4               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute5               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute6               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute7               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute8               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute9               No   varchar2  Descriptive Flexfield
--   p_vpf_attribute10              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute11              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute12              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute13              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute14              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute15              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute16              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute17              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute18              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute19              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute20              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute21              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute22              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute23              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute24              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute25              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute26              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute27              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute28              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute29              No   varchar2  Descriptive Flexfield
--   p_vpf_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_vrbl_rate_profile
  (p_validate                       in boolean    default false
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
  ,p_rt_qua_in_gr_flag    	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_perf_rtng_flag    	    in  varchar2  default hr_api.g_varchar2
  ,p_rt_elig_prfl_flag    	    in  varchar2  default hr_api.g_varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_vrbl_rate_profile >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_vrbl_rt_prfl_id              Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_vrbl_rate_profile
  (p_validate                       in boolean        default false
  ,p_vrbl_rt_prfl_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2);
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_vrbl_rt_prfl_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  ( p_vrbl_rt_prfl_id              in number
   ,p_object_version_number        in number
   ,p_effective_date               in date
   ,p_datetrack_mode               in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date);
--
end ben_vrbl_rate_profile_api;

 

/
