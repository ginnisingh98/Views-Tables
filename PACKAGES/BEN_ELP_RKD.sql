--------------------------------------------------------
--  DDL for Package BEN_ELP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELP_RKD" AUTHID CURRENT_USER as
/* $Header: beelprhi.pkh 120.1.12000000.1 2007/01/19 05:29:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_eligy_prfl_id                  in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_description_o                  in varchar2
 ,p_stat_cd_o                      in varchar2
 ,p_asmt_to_use_cd_o               in varchar2
 ,p_elig_enrld_plip_flag_o         in varchar2
 ,p_elig_cbr_quald_bnf_flag_o      in varchar2
 ,p_elig_enrld_ptip_flag_o         in varchar2
 ,p_elig_dpnt_cvrd_plip_flag_o     in varchar2
 ,p_elig_dpnt_cvrd_ptip_flag_o     in varchar2
 ,p_elig_dpnt_cvrd_pgm_flag_o      in varchar2
 ,p_elig_job_flag_o                in varchar2
 ,p_elig_hrly_slrd_flag_o          in varchar2
 ,p_elig_pstl_cd_flag_o            in varchar2
 ,p_elig_lbr_mmbr_flag_o           in varchar2
 ,p_elig_lgl_enty_flag_o           in varchar2
 ,p_elig_benfts_grp_flag_o         in varchar2
 ,p_elig_wk_loc_flag_o             in varchar2
 ,p_elig_brgng_unit_flag_o         in varchar2
 ,p_elig_age_flag_o                in varchar2
 ,p_elig_los_flag_o                in varchar2
 ,p_elig_per_typ_flag_o            in varchar2
 ,p_elig_fl_tm_pt_tm_flag_o        in varchar2
 ,p_elig_ee_stat_flag_o            in varchar2
 ,p_elig_grd_flag_o                in varchar2
 ,p_elig_pct_fl_tm_flag_o          in varchar2
 ,p_elig_asnt_set_flag_o           in varchar2
 ,p_elig_hrs_wkd_flag_o            in varchar2
 ,p_elig_comp_lvl_flag_o           in varchar2
 ,p_elig_org_unit_flag_o           in varchar2
 ,p_elig_loa_rsn_flag_o            in varchar2
 ,p_elig_pyrl_flag_o               in varchar2
 ,p_elig_schedd_hrs_flag_o         in varchar2
 ,p_elig_py_bss_flag_o             in varchar2
 ,p_eligy_prfl_rl_flag_o           in varchar2
 ,p_elig_cmbn_age_los_flag_o       in varchar2
 ,p_cntng_prtn_elig_prfl_flag_o    in varchar2
 ,p_elig_prtt_pl_flag_o            in varchar2
 ,p_elig_ppl_grp_flag_o            in varchar2
 ,p_elig_svc_area_flag_o           in varchar2
 ,p_elig_ptip_prte_flag_o          in varchar2
 ,p_elig_no_othr_cvg_flag_o        in varchar2
 ,p_elig_enrld_pl_flag_o           in varchar2
 ,p_elig_enrld_oipl_flag_o         in varchar2
 ,p_elig_enrld_pgm_flag_o          in varchar2
 ,p_elig_dpnt_cvrd_pl_flag_o       in varchar2
 ,p_elig_lvg_rsn_flag_o            in varchar2
 ,p_elig_optd_mdcr_flag_o          in varchar2
 ,p_elig_tbco_use_flag_o           in varchar2
 ,p_elig_dpnt_othr_ptip_flag_o     in varchar2
 ,p_business_group_id_o            in number
 ,p_elp_attribute_category_o       in varchar2
 ,p_elp_attribute1_o               in varchar2
 ,p_elp_attribute2_o               in varchar2
 ,p_elp_attribute3_o               in varchar2
 ,p_elp_attribute4_o               in varchar2
 ,p_elp_attribute5_o               in varchar2
 ,p_elp_attribute6_o               in varchar2
 ,p_elp_attribute7_o               in varchar2
 ,p_elp_attribute8_o               in varchar2
 ,p_elp_attribute9_o               in varchar2
 ,p_elp_attribute10_o              in varchar2
 ,p_elp_attribute11_o              in varchar2
 ,p_elp_attribute12_o              in varchar2
 ,p_elp_attribute13_o              in varchar2
 ,p_elp_attribute14_o              in varchar2
 ,p_elp_attribute15_o              in varchar2
 ,p_elp_attribute16_o              in varchar2
 ,p_elp_attribute17_o              in varchar2
 ,p_elp_attribute18_o              in varchar2
 ,p_elp_attribute19_o              in varchar2
 ,p_elp_attribute20_o              in varchar2
 ,p_elp_attribute21_o              in varchar2
 ,p_elp_attribute22_o              in varchar2
 ,p_elp_attribute23_o              in varchar2
 ,p_elp_attribute24_o              in varchar2
 ,p_elp_attribute25_o              in varchar2
 ,p_elp_attribute26_o              in varchar2
 ,p_elp_attribute27_o              in varchar2
 ,p_elp_attribute28_o              in varchar2
 ,p_elp_attribute29_o              in varchar2
 ,p_elp_attribute30_o              in varchar2
 ,p_elig_mrtl_sts_flag_o           in varchar2
 ,p_elig_gndr_flag_o               in varchar2
 ,p_elig_dsblty_ctg_flag_o         in varchar2
 ,p_elig_dsblty_rsn_flag_o         in varchar2
 ,p_elig_dsblty_dgr_flag_o         in varchar2
 ,p_elig_suppl_role_flag_o         in varchar2
 ,p_elig_qual_titl_flag_o          in varchar2
 ,p_elig_pstn_flag_o               in varchar2
 ,p_elig_prbtn_perd_flag_o         in varchar2
 ,p_elig_sp_clng_prg_pt_flag_o     in varchar2
 ,p_bnft_cagr_prtn_cd_o            in varchar2
 ,p_elig_dsbld_flag_o              in varchar2
 ,p_elig_ttl_cvg_vol_flag_o        in varchar2
 ,p_elig_ttl_prtt_flag_o           in varchar2
 ,p_elig_comptncy_flag_o           in varchar2
 ,p_elig_hlth_cvg_flag_o	   in varchar2
 ,p_elig_anthr_pl_flag_o	   in varchar2
 ,p_elig_qua_in_gr_flag_o	   in varchar2
 ,p_elig_perf_rtng_flag_o	   in varchar2
 ,p_elig_crit_values_flag_o        in varchar2   /* RBC */
 ,p_object_version_number_o        in number
  );
--
end ben_elp_rkd;

 

/
