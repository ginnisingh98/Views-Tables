--------------------------------------------------------
--  DDL for Package BEN_VPF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VPF_RKD" AUTHID CURRENT_USER as
/* $Header: bevpfrhi.pkh 120.0.12010000.1 2008/07/29 13:07:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_vrbl_rt_prfl_id                in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_pl_typ_opt_typ_id_o            in number
 ,p_pl_id_o                        in number
 ,p_oipl_id_o                      in number
 ,p_comp_lvl_fctr_id_o             in number
 ,p_business_group_id_o            in number
 ,p_acty_typ_cd_o                  in varchar2
 ,p_rt_typ_cd_o                    in varchar2
 ,p_bnft_rt_typ_cd_o               in varchar2
 ,p_tx_typ_cd_o                    in varchar2
 ,p_vrbl_rt_trtmt_cd_o             in varchar2
 ,p_acty_ref_perd_cd_o             in varchar2
 ,p_mlt_cd_o                       in varchar2
 ,p_incrmnt_elcn_val_o             in number
 ,p_dflt_elcn_val_o                in number
 ,p_mx_elcn_val_o                  in number
 ,p_mn_elcn_val_o                  in number
 ,p_lwr_lmt_val_o                  in number
 ,p_lwr_lmt_calc_rl_o              in number
 ,p_upr_lmt_val_o                  in number
 ,p_upr_lmt_calc_rl_o              in number
 ,p_ultmt_upr_lmt_o                in number
 ,p_ultmt_lwr_lmt_o                in number
 ,p_ultmt_upr_lmt_calc_rl_o        in number
 ,p_ultmt_lwr_lmt_calc_rl_o        in number
 ,p_ann_mn_elcn_val_o              in number
 ,p_ann_mx_elcn_val_o              in number
 ,p_val_o                          in number
 ,p_name_o                         in varchar2
 ,p_no_mn_elcn_val_dfnd_flag_o     in varchar2
 ,p_no_mx_elcn_val_dfnd_flag_o     in varchar2
 ,p_alwys_sum_all_cvg_flag_o       in varchar2
 ,p_alwys_cnt_all_prtts_flag_o     in varchar2
 ,p_val_calc_rl_o                  in number
 ,p_vrbl_rt_prfl_stat_cd_o         in varchar2
 ,p_vrbl_usg_cd_o                  in varchar2
 ,p_asmt_to_use_cd_o               in varchar2
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_rt_hrly_slrd_flag_o            in varchar2
 ,p_rt_pstl_cd_flag_o              in varchar2
 ,p_rt_lbr_mmbr_flag_o             in varchar2
 ,p_rt_lgl_enty_flag_o             in varchar2
 ,p_rt_benfts_grp_flag_o           in varchar2
 ,p_rt_wk_loc_flag_o               in varchar2
 ,p_rt_brgng_unit_flag_o           in varchar2
 ,p_rt_age_flag_o                  in varchar2
 ,p_rt_los_flag_o                  in varchar2
 ,p_rt_per_typ_flag_o              in varchar2
 ,p_rt_fl_tm_pt_tm_flag_o          in varchar2
 ,p_rt_ee_stat_flag_o              in varchar2
 ,p_rt_grd_flag_o                  in varchar2
 ,p_rt_pct_fl_tm_flag_o            in varchar2
 ,p_rt_asnt_set_flag_o             in varchar2
 ,p_rt_hrs_wkd_flag_o              in varchar2
 ,p_rt_comp_lvl_flag_o             in varchar2
 ,p_rt_org_unit_flag_o             in varchar2
 ,p_rt_loa_rsn_flag_o              in varchar2
 ,p_rt_pyrl_flag_o                 in varchar2
 ,p_rt_schedd_hrs_flag_o           in varchar2
 ,p_rt_py_bss_flag_o               in varchar2
 ,p_rt_prfl_rl_flag_o              in varchar2
 ,p_rt_cmbn_age_los_flag_o         in varchar2
 ,p_rt_prtt_pl_flag_o              in varchar2
 ,p_rt_svc_area_flag_o             in varchar2
 ,p_rt_ppl_grp_flag_o              in varchar2
 ,p_rt_dsbld_flag_o                in varchar2
 ,p_rt_hlth_cvg_flag_o             in varchar2
 ,p_rt_poe_flag_o                  in varchar2
 ,p_rt_ttl_cvg_vol_flag_o          in varchar2
 ,p_rt_ttl_prtt_flag_o             in varchar2
 ,p_rt_gndr_flag_o                 in varchar2
 ,p_rt_tbco_use_flag_o             in varchar2
 ,p_vpf_attribute_category_o       in varchar2
 ,p_vpf_attribute1_o               in varchar2
 ,p_vpf_attribute2_o               in varchar2
 ,p_vpf_attribute3_o               in varchar2
 ,p_vpf_attribute4_o               in varchar2
 ,p_vpf_attribute5_o               in varchar2
 ,p_vpf_attribute6_o               in varchar2
 ,p_vpf_attribute7_o               in varchar2
 ,p_vpf_attribute8_o               in varchar2
 ,p_vpf_attribute9_o               in varchar2
 ,p_vpf_attribute10_o              in varchar2
 ,p_vpf_attribute11_o              in varchar2
 ,p_vpf_attribute12_o              in varchar2
 ,p_vpf_attribute13_o              in varchar2
 ,p_vpf_attribute14_o              in varchar2
 ,p_vpf_attribute15_o              in varchar2
 ,p_vpf_attribute16_o              in varchar2
 ,p_vpf_attribute17_o              in varchar2
 ,p_vpf_attribute18_o              in varchar2
 ,p_vpf_attribute19_o              in varchar2
 ,p_vpf_attribute20_o              in varchar2
 ,p_vpf_attribute21_o              in varchar2
 ,p_vpf_attribute22_o              in varchar2
 ,p_vpf_attribute23_o              in varchar2
 ,p_vpf_attribute24_o              in varchar2
 ,p_vpf_attribute25_o              in varchar2
 ,p_vpf_attribute26_o              in varchar2
 ,p_vpf_attribute27_o              in varchar2
 ,p_vpf_attribute28_o              in varchar2
 ,p_vpf_attribute29_o              in varchar2
 ,p_vpf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_rt_cntng_prtn_prfl_flag_o      in varchar2
 ,p_rt_cbr_quald_bnf_flag_o        in varchar2
 ,p_rt_optd_mdcr_flag_o            in varchar2
 ,p_rt_lvg_rsn_flag_o              in varchar2
 ,p_rt_pstn_flag_o                 in varchar2
 ,p_rt_comptncy_flag_o             in varchar2
 ,p_rt_job_flag_o                  in varchar2
 ,p_rt_qual_titl_flag_o            in varchar2
 ,p_rt_dpnt_cvrd_pl_flag_o         in varchar2
 ,p_rt_dpnt_cvrd_plip_flag_o       in varchar2
 ,p_rt_dpnt_cvrd_ptip_flag_o       in varchar2
 ,p_rt_dpnt_cvrd_pgm_flag_o        in varchar2
 ,p_rt_enrld_oipl_flag_o           in varchar2
 ,p_rt_enrld_pl_flag_o             in varchar2
 ,p_rt_enrld_plip_flag_o           in varchar2
 ,p_rt_enrld_ptip_flag_o           in varchar2
 ,p_rt_enrld_pgm_flag_o            in varchar2
 ,p_rt_prtt_anthr_pl_flag_o        in varchar2
 ,p_rt_othr_ptip_flag_o            in varchar2
 ,p_rt_no_othr_cvg_flag_o          in varchar2
 ,p_rt_dpnt_othr_ptip_flag_o       in varchar2
 ,p_rt_qua_in_gr_flag_o            in varchar2
 ,p_rt_perf_rtng_flag_o  	   in varchar2
 ,p_rt_elig_prfl_flag_o  	   in varchar2
 );
--
end ben_vpf_rkd;

/
