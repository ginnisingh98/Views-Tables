--------------------------------------------------------
--  DDL for Package BEN_PGM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_RKD" AUTHID CURRENT_USER as
/* $Header: bepgmrhi.pkh 120.0 2005/05/28 10:47:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pgm_id                         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_dpnt_adrs_rqd_flag_o           in varchar2
 ,p_pgm_prvds_no_auto_enrt_fla_o  in varchar2
 ,p_dpnt_dob_rqd_flag_o            in varchar2
 ,p_pgm_prvds_no_dflt_enrt_fla_o  in varchar2
 ,p_dpnt_legv_id_rqd_flag_o        in varchar2
 ,p_dpnt_dsgn_lvl_cd_o             in varchar2
 ,p_pgm_stat_cd_o                  in varchar2
 ,p_ivr_ident_o                    in varchar2
 ,p_pgm_typ_cd_o                   in varchar2
 ,p_elig_apls_flag_o               in varchar2
 ,p_uses_all_asmts_for_rts_fla_o   in varchar2
 ,p_url_ref_name_o                 in varchar2
 ,p_pgm_desc_o                     in varchar2
 ,p_prtn_elig_ovrid_alwd_flag_o    in varchar2
 ,p_pgm_use_all_asnts_elig_fla_o  in varchar2
 ,p_dpnt_dsgn_cd_o                 in varchar2
 ,p_mx_dpnt_pct_prtt_lf_amt_o      in number
 ,p_mx_sps_pct_prtt_lf_amt_o       in number
 ,p_acty_ref_perd_cd_o             in varchar2
 ,p_coord_cvg_for_all_pls_flg_o    in varchar2
 ,p_enrt_cvg_end_dt_cd_o           in varchar2
 ,p_enrt_cvg_end_dt_rl_o           in number
 ,p_dpnt_cvg_end_dt_cd_o           in varchar2
 ,p_dpnt_cvg_end_dt_rl_o           in number
 ,p_dpnt_cvg_strt_dt_cd_o          in varchar2
 ,p_dpnt_cvg_strt_dt_rl_o          in number
 ,p_dpnt_dsgn_no_ctfn_rqd_flag_o   in varchar2
 ,p_drvbl_fctr_dpnt_elig_flag_o    in varchar2
 ,p_drvbl_fctr_prtn_elig_flag_o    in varchar2
 ,p_enrt_cvg_strt_dt_cd_o          in varchar2
 ,p_enrt_cvg_strt_dt_rl_o          in number
 ,p_enrt_info_rt_freq_cd_o         in varchar2
 ,p_rt_strt_dt_cd_o                in varchar2
 ,p_rt_strt_dt_rl_o                in number
 ,p_rt_end_dt_cd_o                 in varchar2
 ,p_rt_end_dt_rl_o                 in number
 ,p_pgm_grp_cd_o                   in varchar2
 ,p_pgm_uom_o                      in varchar2
 ,p_drvbl_fctr_apls_rts_flag_o     in varchar2
 ,p_alws_unrstrctd_enrt_flag_o     in varchar2
 ,p_enrt_cd_o                      in varchar2
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_poe_lvl_cd_o                   in varchar2
 ,p_enrt_rl_o                      in number
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_trk_inelig_per_flag_o          in varchar2
 ,p_business_group_id_o            in number
 ,p_per_cvrd_cd_o                  in varchar2
 ,P_vrfy_fmly_mmbr_rl_o            in number
 ,P_vrfy_fmly_mmbr_cd_o            in varchar2
 ,p_short_name_o		   in varchar2  /*FHR*/
 ,p_short_code_o		   in varchar2  /*FHR*/
  ,p_legislation_code_o		   in varchar2  /*FHR*/
  ,p_legislation_subgroup_o		   in varchar2  /*FHR*/
 ,p_Dflt_pgm_flag_o                in  Varchar2
 ,p_Use_prog_points_flag_o         in  Varchar2
 ,p_Dflt_step_cd_o                 in  Varchar2
 ,p_Dflt_step_rl_o                 in  number
 ,p_Update_salary_cd_o             in  Varchar2
 ,p_Use_multi_pay_rates_flag_o     in  Varchar2
 ,p_dflt_element_type_id_o         in  number
 ,p_Dflt_input_value_id_o          in  number
 ,p_Use_scores_cd_o                in  Varchar2
 ,p_Scores_calc_mthd_cd_o          in  Varchar2
 ,p_Scores_calc_rl_o               in  number
 ,p_gsp_allow_override_flag_o       in varchar2
 ,p_use_variable_rates_flag_o       in varchar2
 ,p_salary_calc_mthd_cd_o       in varchar2
 ,p_salary_calc_mthd_rl_o       in number
 ,p_susp_if_dpnt_ssn_nt_prv_cd_o    in  varchar2
 ,p_susp_if_dpnt_dob_nt_prv_cd_o    in  varchar2
 ,p_susp_if_dpnt_adr_nt_prv_cd_o    in  varchar2
 ,p_susp_if_ctfn_not_dpnt_flag_o    in  varchar2
 ,p_dpnt_ctfn_determine_cd_o        in  varchar2
 ,p_pgm_attribute_category_o       in varchar2
 ,p_pgm_attribute1_o               in varchar2
 ,p_pgm_attribute2_o               in varchar2
 ,p_pgm_attribute3_o               in varchar2
 ,p_pgm_attribute4_o               in varchar2
 ,p_pgm_attribute5_o               in varchar2
 ,p_pgm_attribute6_o               in varchar2
 ,p_pgm_attribute7_o               in varchar2
 ,p_pgm_attribute8_o               in varchar2
 ,p_pgm_attribute9_o               in varchar2
 ,p_pgm_attribute10_o              in varchar2
 ,p_pgm_attribute11_o              in varchar2
 ,p_pgm_attribute12_o              in varchar2
 ,p_pgm_attribute13_o              in varchar2
 ,p_pgm_attribute14_o              in varchar2
 ,p_pgm_attribute15_o              in varchar2
 ,p_pgm_attribute16_o              in varchar2
 ,p_pgm_attribute17_o              in varchar2
 ,p_pgm_attribute18_o              in varchar2
 ,p_pgm_attribute19_o              in varchar2
 ,p_pgm_attribute20_o              in varchar2
 ,p_pgm_attribute21_o              in varchar2
 ,p_pgm_attribute22_o              in varchar2
 ,p_pgm_attribute23_o              in varchar2
 ,p_pgm_attribute24_o              in varchar2
 ,p_pgm_attribute25_o              in varchar2
 ,p_pgm_attribute26_o              in varchar2
 ,p_pgm_attribute27_o              in varchar2
 ,p_pgm_attribute28_o              in varchar2
 ,p_pgm_attribute29_o              in varchar2
 ,p_pgm_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pgm_rkd;

 

/
