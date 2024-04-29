--------------------------------------------------------
--  DDL for Package BEN_ELIGY_PROFILE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_PROFILE_API" AUTHID CURRENT_USER as
/* $Header: beelpapi.pkh 120.0 2005/05/28 02:19:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIGY_PROFILE >--------------------------|
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
--   p_name                         Yes  varchar2
--   p_description                  No   varchar2
--   p_stat_cd                      Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_elp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_elp_attribute1               No   varchar2  Descriptive Flexfield
--   p_elp_attribute2               No   varchar2  Descriptive Flexfield
--   p_elp_attribute3               No   varchar2  Descriptive Flexfield
--   p_elp_attribute4               No   varchar2  Descriptive Flexfield
--   p_elp_attribute5               No   varchar2  Descriptive Flexfield
--   p_elp_attribute6               No   varchar2  Descriptive Flexfield
--   p_elp_attribute7               No   varchar2  Descriptive Flexfield
--   p_elp_attribute8               No   varchar2  Descriptive Flexfield
--   p_elp_attribute9               No   varchar2  Descriptive Flexfield
--   p_elp_attribute10              No   varchar2  Descriptive Flexfield
--   p_elp_attribute11              No   varchar2  Descriptive Flexfield
--   p_elp_attribute12              No   varchar2  Descriptive Flexfield
--   p_elp_attribute13              No   varchar2  Descriptive Flexfield
--   p_elp_attribute14              No   varchar2  Descriptive Flexfield
--   p_elp_attribute15              No   varchar2  Descriptive Flexfield
--   p_elp_attribute16              No   varchar2  Descriptive Flexfield
--   p_elp_attribute17              No   varchar2  Descriptive Flexfield
--   p_elp_attribute18              No   varchar2  Descriptive Flexfield
--   p_elp_attribute19              No   varchar2  Descriptive Flexfield
--   p_elp_attribute20              No   varchar2  Descriptive Flexfield
--   p_elp_attribute21              No   varchar2  Descriptive Flexfield
--   p_elp_attribute22              No   varchar2  Descriptive Flexfield
--   p_elp_attribute23              No   varchar2  Descriptive Flexfield
--   p_elp_attribute24              No   varchar2  Descriptive Flexfield
--   p_elp_attribute25              No   varchar2  Descriptive Flexfield
--   p_elp_attribute26              No   varchar2  Descriptive Flexfield
--   p_elp_attribute27              No   varchar2  Descriptive Flexfield
--   p_elp_attribute28              No   varchar2  Descriptive Flexfield
--   p_elp_attribute29              No   varchar2  Descriptive Flexfield
--   p_elp_attribute30              No   varchar2  Descriptive Flexfield
--   p_elig_mrtl_sts_flag           yes  varchar2
--   p_elig_gndr_flag               yes  varchar2
--   p_elig_dsblty_ctg_flag         yes  varchar2
--   p_elig_dsblty_rsn_flag         yes  varchar2
--   p_elig_dsblty_dgr_flag         yes  varchar2
--   p_elig_suppl_role_flag         yes  varchar2
--   p_elig_qual_titl_flag          yes  varchar2
--   p_elig_pstn_flag               yes  varchar2
--   p_elig_prbtn_perd_flag         yes  varchar2
--   p_elig_sp_clng_prg_pt_flag     yes  varchar2
--   p_bnft_cagr_prtn_cd            yes  varchar2
--   p_elig_dsbld_flag        	    yes  varchar2
--   p_elig_ttl_cvg_vol_flag  	    yes  varchar2
--   p_elig_ttl_prtt_flag     	    yes  varchar2
--   p_elig_comptncy_flag     	    yes  varchar2
--   p_elig_hlth_cvg_flag  	    yes  varchar2
--   p_elig_anthr_pl_flag  	    yes  varchar2
--   p_elig_qua_in_gr_flag  	    yes  varchar2
--   p_elig_perf_rtng_flag  	    yes  varchar2
--   p_elig_crit_values_flag        yes  varchar2   /* RBC */
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
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
procedure create_ELIGY_PROFILE
  (p_validate                       in boolean    default false
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
  ,p_elig_crit_values_flag          in  varchar2  default 'N'   /* RBC */
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date);
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIGY_PROFILE >--------------------------|
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
--   p_eligy_prfl_id                Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_description                  No   varchar2
--   p_stat_cd                      Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_elp_attribute_category       No   varchar2  Descriptive Flexfield
--   p_elp_attribute1               No   varchar2  Descriptive Flexfield
--   p_elp_attribute2               No   varchar2  Descriptive Flexfield
--   p_elp_attribute3               No   varchar2  Descriptive Flexfield
--   p_elp_attribute4               No   varchar2  Descriptive Flexfield
--   p_elp_attribute5               No   varchar2  Descriptive Flexfield
--   p_elp_attribute6               No   varchar2  Descriptive Flexfield
--   p_elp_attribute7               No   varchar2  Descriptive Flexfield
--   p_elp_attribute8               No   varchar2  Descriptive Flexfield
--   p_elp_attribute9               No   varchar2  Descriptive Flexfield
--   p_elp_attribute10              No   varchar2  Descriptive Flexfield
--   p_elp_attribute11              No   varchar2  Descriptive Flexfield
--   p_elp_attribute12              No   varchar2  Descriptive Flexfield
--   p_elp_attribute13              No   varchar2  Descriptive Flexfield
--   p_elp_attribute14              No   varchar2  Descriptive Flexfield
--   p_elp_attribute15              No   varchar2  Descriptive Flexfield
--   p_elp_attribute16              No   varchar2  Descriptive Flexfield
--   p_elp_attribute17              No   varchar2  Descriptive Flexfield
--   p_elp_attribute18              No   varchar2  Descriptive Flexfield
--   p_elp_attribute19              No   varchar2  Descriptive Flexfield
--   p_elp_attribute20              No   varchar2  Descriptive Flexfield
--   p_elp_attribute21              No   varchar2  Descriptive Flexfield
--   p_elp_attribute22              No   varchar2  Descriptive Flexfield
--   p_elp_attribute23              No   varchar2  Descriptive Flexfield
--   p_elp_attribute24              No   varchar2  Descriptive Flexfield
--   p_elp_attribute25              No   varchar2  Descriptive Flexfield
--   p_elp_attribute26              No   varchar2  Descriptive Flexfield
--   p_elp_attribute27              No   varchar2  Descriptive Flexfield
--   p_elp_attribute28              No   varchar2  Descriptive Flexfield
--   p_elp_attribute29              No   varchar2  Descriptive Flexfield
--   p_elp_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--   p_elig_dsbld_flag        	    yes  varchar2
--   p_elig_ttl_cvg_vol_flag  	    yes  varchar2
--   p_elig_ttl_prtt_flag     	    yes  varchar2
--   p_elig_comptncy_flag     	    yes  varchar2
--   p_elig_hlth_cvg_flag  	    yes  varchar2
--   p_elig_anthr_pl_flag  	    yes  varchar2
--   p_elig_qua_in_gr_flag	    yes  varchar2
--   p_elig_perf_rtng_flag	    yes  varchar2
--   p_elig_crit_values_flag        yes  varchar2   /* RBC */
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
procedure update_ELIGY_PROFILE
  (p_validate                       in boolean    default false
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
  ,p_elig_crit_values_flag          in  varchar2  default hr_api.g_varchar2   /* RBC */
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIGY_PROFILE >--------------------------|
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
--   p_eligy_prfl_id                Yes  number    PK of record
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
procedure delete_ELIGY_PROFILE
  (p_validate                       in boolean        default false
  ,p_eligy_prfl_id                  in  number
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
--   p_eligy_prfl_id                 Yes  number   PK of record
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
   (p_eligy_prfl_id               in number
   ,p_object_version_number       in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date       out nocopy date
   ,p_validation_end_date         out nocopy date);
--
end ben_ELIGY_PROFILE_api;

 

/
