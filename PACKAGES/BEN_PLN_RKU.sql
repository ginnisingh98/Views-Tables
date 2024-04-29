--------------------------------------------------------
--  DDL for Package BEN_PLN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLN_RKU" AUTHID CURRENT_USER as
/* $Header: beplnrhi.pkh 120.2.12010000.1 2008/07/29 12:51:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pl_id                          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_alws_qdro_flag                 in varchar2
 ,p_alws_qmcso_flag                in varchar2
 ,p_alws_reimbmts_flag             in varchar2
 ,p_bnf_addl_instn_txt_alwd_flag   in varchar2
 ,p_bnf_adrs_rqd_flag              in varchar2
 ,p_bnf_cntngt_bnfs_alwd_flag      in varchar2
 ,p_bnf_ctfn_rqd_flag              in varchar2
 ,p_bnf_dob_rqd_flag               in varchar2
 ,p_bnf_dsge_mnr_ttee_rqd_flag     in varchar2
 ,p_bnf_incrmt_amt                 in number
 ,p_bnf_dflt_bnf_cd                in varchar2
 ,p_bnf_legv_id_rqd_flag           in varchar2
 ,p_bnf_may_dsgt_org_flag          in varchar2
 ,p_bnf_mn_dsgntbl_amt             in number
 ,p_bnf_mn_dsgntbl_pct_val         in number
 ,p_rqd_perd_enrt_nenrt_val         in number
 ,p_ordr_num         in number
 ,p_bnf_pct_incrmt_val             in number
 ,p_bnf_pct_amt_alwd_cd            in varchar2
 ,p_bnf_qdro_rl_apls_flag          in varchar2
 ,p_dflt_to_asn_pndg_ctfn_cd       in varchar2
 ,p_dflt_to_asn_pndg_ctfn_rl       in number
 ,p_drvbl_fctr_apls_rts_flag       in varchar2
 ,p_drvbl_fctr_prtn_elig_flag      in varchar2
 ,p_dpnt_dsgn_cd                   in varchar2
 ,p_elig_apls_flag                 in varchar2
 ,p_invk_dcln_prtn_pl_flag         in varchar2
 ,p_invk_flx_cr_pl_flag            in varchar2
 ,p_imptd_incm_calc_cd             in varchar2
 ,p_drvbl_dpnt_elig_flag           in varchar2
 ,p_trk_inelig_per_flag            in varchar2
 ,p_pl_cd                          in varchar2
 ,p_auto_enrt_mthd_rl              in number
 ,p_ivr_ident                      in varchar2
 ,p_url_ref_name                   in varchar2
 ,p_cmpr_clms_to_cvg_or_bal_cd     in varchar2
 ,p_cobra_pymt_due_dy_num          in number
 ,p_dpnt_cvd_by_othr_apls_flag     in varchar2
 ,p_enrt_mthd_cd                   in varchar2
 ,p_enrt_cd                        in varchar2
 ,p_enrt_cvg_strt_dt_cd            in varchar2
 ,p_enrt_cvg_end_dt_cd             in varchar2
 ,p_frfs_aply_flag                 in varchar2
 ,p_hc_pl_subj_hcfa_aprvl_flag     in varchar2
 ,p_hghly_cmpd_rl_apls_flag        in varchar2
 ,p_incptn_dt                      in date
 ,p_mn_cvg_rl                      in number
 ,p_mn_cvg_rqd_amt                 in number
 ,p_mn_opts_rqd_num                in number
 ,p_mx_cvg_alwd_amt                in number
 ,p_mx_cvg_rl                      in number
 ,p_mx_opts_alwd_num               in number
 ,p_mx_cvg_wcfn_mlt_num            in number
 ,p_mx_cvg_wcfn_amt                in number
 ,p_mx_cvg_incr_alwd_amt           in number
 ,p_mx_cvg_incr_wcf_alwd_amt       in number
 ,p_mx_cvg_mlt_incr_num            in number
 ,p_mx_cvg_mlt_incr_wcf_num        in number
 ,p_mx_wtg_dt_to_use_cd            in varchar2
 ,p_mx_wtg_dt_to_use_rl            in number
 ,p_mx_wtg_perd_prte_uom           in varchar2
 ,p_mx_wtg_perd_prte_val           in number
 ,p_mx_wtg_perd_rl                 in number
 ,p_nip_dflt_enrt_cd               in varchar2
 ,p_nip_dflt_enrt_det_rl           in number
 ,p_dpnt_adrs_rqd_flag             in varchar2
 ,p_dpnt_cvg_end_dt_cd             in varchar2
 ,p_dpnt_cvg_end_dt_rl             in number
 ,p_dpnt_cvg_strt_dt_cd            in varchar2
 ,p_dpnt_cvg_strt_dt_rl            in number
 ,p_dpnt_dob_rqd_flag              in varchar2
 ,p_dpnt_leg_id_rqd_flag           in varchar2
 ,p_dpnt_no_ctfn_rqd_flag          in varchar2
 ,p_no_mn_cvg_amt_apls_flag        in varchar2
 ,p_no_mn_cvg_incr_apls_flag       in varchar2
 ,p_no_mn_opts_num_apls_flag       in varchar2
 ,p_no_mx_cvg_amt_apls_flag        in varchar2
 ,p_no_mx_cvg_incr_apls_flag       in varchar2
 ,p_no_mx_opts_num_apls_flag       in varchar2
 ,p_nip_pl_uom                     in varchar2
 ,p_rqd_perd_enrt_nenrt_uom        in varchar2
 ,p_nip_acty_ref_perd_cd           in varchar2
 ,p_nip_enrt_info_rt_freq_cd       in varchar2
 ,p_per_cvrd_cd                    in varchar2
 ,p_enrt_cvg_end_dt_rl             in number
 ,p_postelcn_edit_rl               in number
 ,p_enrt_cvg_strt_dt_rl            in number
 ,p_prort_prtl_yr_cvg_rstrn_cd     in varchar2
 ,p_prort_prtl_yr_cvg_rstrn_rl     in number
 ,p_prtn_elig_ovrid_alwd_flag      in varchar2
 ,p_svgs_pl_flag                   in varchar2
 ,p_subj_to_imptd_incm_typ_cd      in varchar2
 ,p_use_all_asnts_elig_flag        in varchar2
 ,p_use_all_asnts_for_rt_flag      in varchar2
 ,p_vstg_apls_flag                 in varchar2
 ,p_wvbl_flag                      in varchar2
 ,p_hc_svc_typ_cd                  in varchar2
 ,p_pl_stat_cd                     in varchar2
 ,p_prmry_fndg_mthd_cd             in varchar2
 ,p_rt_end_dt_cd                   in varchar2
 ,p_rt_end_dt_rl                   in number
 ,p_rt_strt_dt_rl                  in number
 ,p_rt_strt_dt_cd                  in varchar2
 ,p_bnf_dsgn_cd                    in varchar2
 ,p_pl_typ_id                      in number
 ,p_business_group_id              in number
 ,p_enrt_pl_opt_flag               in varchar2
 ,p_bnft_prvdr_pool_id             in number
 ,p_may_ENRL_PL_N_OIPL_FLAG        in varchar2
 ,p_ENRT_RL                        in NUMBER
 ,p_rqd_perd_enrt_nenrt_rl                        in NUMBER
 ,p_ALWS_UNRSTRCTD_ENRT_FLAG       in VARCHAR2
 ,p_BNFT_OR_OPTION_RSTRCTN_CD      in VARCHAR2
 ,p_CVG_INCR_R_DECR_ONLY_CD        in VARCHAR2
 ,p_unsspnd_enrt_cd                in varchar2
 ,p_pln_attribute_category         in varchar2
 ,p_pln_attribute1                 in varchar2
 ,p_pln_attribute2                 in varchar2
 ,p_pln_attribute3                 in varchar2
 ,p_pln_attribute4                 in varchar2
 ,p_pln_attribute5                 in varchar2
 ,p_pln_attribute6                 in varchar2
 ,p_pln_attribute7                 in varchar2
 ,p_pln_attribute8                 in varchar2
 ,p_pln_attribute9                 in varchar2
 ,p_pln_attribute10                in varchar2
 ,p_pln_attribute11                in varchar2
 ,p_pln_attribute12                in varchar2
 ,p_pln_attribute13                in varchar2
 ,p_pln_attribute14                in varchar2
 ,p_pln_attribute15                in varchar2
 ,p_pln_attribute16                in varchar2
 ,p_pln_attribute17                in varchar2
 ,p_pln_attribute18                in varchar2
 ,p_pln_attribute19                in varchar2
 ,p_pln_attribute20                in varchar2
 ,p_pln_attribute21                in varchar2
 ,p_pln_attribute22                in varchar2
 ,p_pln_attribute23                in varchar2
 ,p_pln_attribute24                in varchar2
 ,p_pln_attribute25                in varchar2
 ,p_pln_attribute26                in varchar2
 ,p_pln_attribute27                in varchar2
 ,p_pln_attribute28                in varchar2
 ,p_pln_attribute29                in varchar2
 ,p_pln_attribute30                in varchar2
 ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
 ,p_ctfn_determine_cd              in  varchar2
 ,p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2
 ,p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2
 ,p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2
 ,p_susp_if_ctfn_not_dpnt_flag     in  varchar2
 ,p_susp_if_bnf_ssn_nt_prv_cd      in  varchar2
 ,p_susp_if_bnf_dob_nt_prv_cd      in  varchar2
 ,p_susp_if_bnf_adr_nt_prv_cd      in  varchar2
 ,p_susp_if_ctfn_not_bnf_flag      in  varchar2
 ,p_dpnt_ctfn_determine_cd         in  varchar2
 ,p_bnf_ctfn_determine_cd          in  varchar2
 ,p_object_version_number          in number
 ,p_ALWS_TMPRY_ID_CRD_FLAG       in VARCHAR2
 ,p_actl_prem_id                   in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_vrfy_fmly_mmbr_cd              in varchar2
 ,p_vrfy_fmly_mmbr_rl              in number
 ,p_nip_dflt_flag                  in varchar2
 ,p_frfs_distr_mthd_cd             in  varchar2
 ,p_frfs_distr_mthd_rl             in  number
 ,p_frfs_cntr_det_cd               in  varchar2
 ,p_frfs_distr_det_cd              in  varchar2
 ,p_cost_alloc_keyflex_1_id        in  number
 ,p_cost_alloc_keyflex_2_id        in  number
 ,p_post_to_gl_flag                in  varchar2
 ,p_frfs_val_det_cd                in  varchar2
 ,p_frfs_mx_cryfwd_val             in  number
 ,p_frfs_portion_det_cd            in  varchar2
 ,p_bndry_perd_cd                  in  varchar2
 ,p_short_name			   in  varchar2
 ,p_short_code			   in  varchar2
 ,p_legislation_code		   in  varchar2
 ,p_legislation_subgroup	   in  varchar2
 ,p_group_pl_id                    in  number
 ,p_mapping_table_name             in  varchar2
 ,p_mapping_table_pk_id            in  number
 ,p_function_code                  in  varchar2
 ,p_pl_yr_not_applcbl_flag         in  varchar2
 ,p_use_csd_rsd_prccng_cd          in  VARCHAR2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_alws_qdro_flag_o               in varchar2
 ,p_alws_qmcso_flag_o              in varchar2
 ,p_alws_reimbmts_flag_o           in varchar2
 ,p_bnf_addl_instn_txt_alwd_fl_o in varchar2
 ,p_bnf_adrs_rqd_flag_o            in varchar2
 ,p_bnf_cntngt_bnfs_alwd_flag_o    in varchar2
 ,p_bnf_ctfn_rqd_flag_o            in varchar2
 ,p_bnf_dob_rqd_flag_o             in varchar2
 ,p_bnf_dsge_mnr_ttee_rqd_flag_o   in varchar2
 ,p_bnf_incrmt_amt_o               in number
 ,p_bnf_dflt_bnf_cd_o              in varchar2
 ,p_bnf_legv_id_rqd_flag_o         in varchar2
 ,p_bnf_may_dsgt_org_flag_o        in varchar2
 ,p_bnf_mn_dsgntbl_amt_o           in number
 ,p_bnf_mn_dsgntbl_pct_val_o       in number
 ,p_rqd_perd_enrt_nenrt_val_o       in number
 ,p_ordr_num_o       in number
 ,p_bnf_pct_incrmt_val_o           in number
 ,p_bnf_pct_amt_alwd_cd_o          in varchar2
 ,p_bnf_qdro_rl_apls_flag_o        in varchar2
 ,p_dflt_to_asn_pndg_ctfn_cd_o     in varchar2
 ,p_dflt_to_asn_pndg_ctfn_rl_o     in number
 ,p_drvbl_fctr_apls_rts_flag_o     in varchar2
 ,p_drvbl_fctr_prtn_elig_flag_o    in varchar2
 ,p_dpnt_dsgn_cd_o                 in varchar2
 ,p_elig_apls_flag_o               in varchar2
 ,p_invk_dcln_prtn_pl_flag_o       in varchar2
 ,p_invk_flx_cr_pl_flag_o          in varchar2
 ,p_imptd_incm_calc_cd_o           in varchar2
 ,p_drvbl_dpnt_elig_flag_o         in varchar2
 ,p_trk_inelig_per_flag_o          in varchar2
 ,p_pl_cd_o                        in varchar2
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_ivr_ident_o                    in varchar2
 ,p_url_ref_name_o                 in varchar2
 ,p_cmpr_clms_to_cvg_or_bal_cd_o   in varchar2
 ,p_cobra_pymt_due_dy_num_o        in number
 ,p_dpnt_cvd_by_othr_apls_flag_o   in varchar2
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_enrt_cd_o                      in varchar2
 ,p_enrt_cvg_strt_dt_cd_o          in varchar2
 ,p_enrt_cvg_end_dt_cd_o           in varchar2
 ,p_frfs_aply_flag_o               in varchar2
 ,p_hc_pl_subj_hcfa_aprvl_flag_o   in varchar2
 ,p_hghly_cmpd_rl_apls_flag_o      in varchar2
 ,p_incptn_dt_o                    in date
 ,p_mn_cvg_rl_o                    in number
 ,p_mn_cvg_rqd_amt_o               in number
 ,p_mn_opts_rqd_num_o              in number
 ,p_mx_cvg_alwd_amt_o              in number
 ,p_mx_cvg_rl_o                    in number
 ,p_mx_opts_alwd_num_o             in number
 ,p_mx_cvg_wcfn_mlt_num_o          in number
 ,p_mx_cvg_wcfn_amt_o              in number
 ,p_mx_cvg_incr_alwd_amt_o         in number
 ,p_mx_cvg_incr_wcf_alwd_amt_o     in number
 ,p_mx_cvg_mlt_incr_num_o          in number
 ,p_mx_cvg_mlt_incr_wcf_num_o      in number
 ,p_mx_wtg_dt_to_use_cd_o          in varchar2
 ,p_mx_wtg_dt_to_use_rl_o          in number
 ,p_mx_wtg_perd_prte_uom_o         in varchar2
 ,p_mx_wtg_perd_prte_val_o         in number
 ,p_mx_wtg_perd_rl_o               in number
 ,p_nip_dflt_enrt_cd_o             in varchar2
 ,p_nip_dflt_enrt_det_rl_o         in number
 ,p_dpnt_adrs_rqd_flag_o           in varchar2
 ,p_dpnt_cvg_end_dt_cd_o           in varchar2
 ,p_dpnt_cvg_end_dt_rl_o           in number
 ,p_dpnt_cvg_strt_dt_cd_o          in varchar2
 ,p_dpnt_cvg_strt_dt_rl_o          in number
 ,p_dpnt_dob_rqd_flag_o            in varchar2
 ,p_dpnt_leg_id_rqd_flag_o         in varchar2
 ,p_dpnt_no_ctfn_rqd_flag_o        in varchar2
 ,p_no_mn_cvg_amt_apls_flag_o      in varchar2
 ,p_no_mn_cvg_incr_apls_flag_o     in varchar2
 ,p_no_mn_opts_num_apls_flag_o     in varchar2
 ,p_no_mx_cvg_amt_apls_flag_o      in varchar2
 ,p_no_mx_cvg_incr_apls_flag_o     in varchar2
 ,p_no_mx_opts_num_apls_flag_o     in varchar2
 ,p_nip_pl_uom_o                   in varchar2
 ,p_rqd_perd_enrt_nenrt_uom_o                   in varchar2
 ,p_nip_acty_ref_perd_cd_o         in varchar2
 ,p_nip_enrt_info_rt_freq_cd_o     in varchar2
 ,p_per_cvrd_cd_o                  in varchar2
 ,p_enrt_cvg_end_dt_rl_o           in number
 ,p_postelcn_edit_rl_o             in number
 ,p_enrt_cvg_strt_dt_rl_o          in number
 ,p_prort_prtl_yr_cvg_rstrn_cd_o   in varchar2
 ,p_prort_prtl_yr_cvg_rstrn_rl_o   in number
 ,p_prtn_elig_ovrid_alwd_flag_o    in varchar2
 ,p_svgs_pl_flag_o                 in varchar2
 ,p_subj_to_imptd_incm_typ_cd_o    in varchar2
 ,p_use_all_asnts_elig_flag_o      in varchar2
 ,p_use_all_asnts_for_rt_flag_o    in varchar2
 ,p_vstg_apls_flag_o               in varchar2
 ,p_wvbl_flag_o                    in varchar2
 ,p_hc_svc_typ_cd_o                in varchar2
 ,p_pl_stat_cd_o                   in varchar2
 ,p_prmry_fndg_mthd_cd_o           in varchar2
 ,p_rt_end_dt_cd_o                 in varchar2
 ,p_rt_end_dt_rl_o                 in number
 ,p_rt_strt_dt_rl_o                in number
 ,p_rt_strt_dt_cd_o                in varchar2
 ,p_bnf_dsgn_cd_o                  in varchar2
 ,p_pl_typ_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_enrt_pl_opt_flag_o             in varchar2
 ,p_bnft_prvdr_pool_id_o           in number
 ,p_MAY_ENRL_PL_N_OIPL_FLAG_o      in VARCHAR2
 ,p_ENRT_RL_o                      in NUMBER
 ,p_rqd_perd_enrt_nenrt_rl_o                      in NUMBER
 ,p_ALWS_UNRSTRCTD_ENRT_FLAG_o     in VARCHAR2
 ,p_BNFT_OR_OPTION_RSTRCTN_CD_o    in VARCHAR2
 ,p_CVG_INCR_R_DECR_ONLY_CD_o      in VARCHAR2
 ,p_unsspnd_enrt_cd_o              in varchar2
 ,p_pln_attribute_category_o       in varchar2
 ,p_pln_attribute1_o               in varchar2
 ,p_pln_attribute2_o               in varchar2
 ,p_pln_attribute3_o               in varchar2
 ,p_pln_attribute4_o               in varchar2
 ,p_pln_attribute5_o               in varchar2
 ,p_pln_attribute6_o               in varchar2
 ,p_pln_attribute7_o               in varchar2
 ,p_pln_attribute8_o               in varchar2
 ,p_pln_attribute9_o               in varchar2
 ,p_pln_attribute10_o              in varchar2
 ,p_pln_attribute11_o              in varchar2
 ,p_pln_attribute12_o              in varchar2
 ,p_pln_attribute13_o              in varchar2
 ,p_pln_attribute14_o              in varchar2
 ,p_pln_attribute15_o              in varchar2
 ,p_pln_attribute16_o              in varchar2
 ,p_pln_attribute17_o              in varchar2
 ,p_pln_attribute18_o              in varchar2
 ,p_pln_attribute19_o              in varchar2
 ,p_pln_attribute20_o              in varchar2
 ,p_pln_attribute21_o              in varchar2
 ,p_pln_attribute22_o              in varchar2
 ,p_pln_attribute23_o              in varchar2
 ,p_pln_attribute24_o              in varchar2
 ,p_pln_attribute25_o              in varchar2
 ,p_pln_attribute26_o              in varchar2
 ,p_pln_attribute27_o              in varchar2
 ,p_pln_attribute28_o              in varchar2
 ,p_pln_attribute29_o              in varchar2
 ,p_pln_attribute30_o              in varchar2
 ,p_susp_if_ctfn_not_prvd_flag_o   in  varchar2
 ,p_ctfn_determine_cd_o            in  varchar2
 ,p_susp_if_dpnt_ssn_nt_prv_cd_o    in  varchar2
 ,p_susp_if_dpnt_dob_nt_prv_cd_o    in  varchar2
 ,p_susp_if_dpnt_adr_nt_prv_cd_o    in  varchar2
 ,p_susp_if_ctfn_not_dpnt_flag_o    in  varchar2
 ,p_susp_if_bnf_ssn_nt_prv_cd_o     in  varchar2
 ,p_susp_if_bnf_dob_nt_prv_cd_o     in  varchar2
 ,p_susp_if_bnf_adr_nt_prv_cd_o     in  varchar2
 ,p_susp_if_ctfn_not_bnf_flag_o     in  varchar2
 ,p_dpnt_ctfn_determine_cd_o        in  varchar2
 ,p_bnf_ctfn_determine_cd_o         in  varchar2
 ,p_object_version_number_o        in number
 ,p_actl_prem_id_o                 in number
 ,p_vrfy_fmly_mmbr_cd_o            in  varchar2
 ,p_vrfy_fmly_mmbr_rl_o            in  number
 ,p_ALWS_TMPRY_ID_CRD_FLAG_o       in VARCHAR2
 ,p_nip_dflt_flag_o                in varchar2
 ,p_frfs_distr_mthd_cd_o           in  varchar2
 ,p_frfs_distr_mthd_rl_o           in  number
 ,p_frfs_cntr_det_cd_o             in  varchar2
 ,p_frfs_distr_det_cd_o            in  varchar2
 ,p_cost_alloc_keyflex_1_id_o      in  number
 ,p_cost_alloc_keyflex_2_id_o      in  number
 ,p_post_to_gl_flag_o              in  varchar2
 ,p_frfs_val_det_cd_o              in  varchar2
 ,p_frfs_mx_cryfwd_val_o           in  number
 ,p_frfs_portion_det_cd_o          in  varchar2
 ,p_bndry_perd_cd_o                in  varchar2
 ,p_short_name_o		    in  varchar2
 ,p_short_code_o		    in  varchar2
  ,p_legislation_code_o		    in  varchar2
  ,p_legislation_subgroup_o	    in  varchar2
 ,p_group_pl_id_o                    in  number
 ,p_mapping_table_name_o           in  varchar2
 ,p_mapping_table_pk_id_o          in  number
 ,p_function_code_o                in  varchar2
 ,p_pl_yr_not_applcbl_flag_o            in  varchar2
 ,p_use_csd_rsd_prccng_cd_o        in  VARCHAR2
  );
--
end ben_pln_rku;

/