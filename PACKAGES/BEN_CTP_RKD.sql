--------------------------------------------------------
--  DDL for Package BEN_CTP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTP_RKD" AUTHID CURRENT_USER as
/* $Header: bectprhi.pkh 120.0 2005/05/28 01:26:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ptip_id                        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_coord_cvg_for_all_pls_flag_o   in varchar2
 ,p_dpnt_dsgn_cd_o                 in varchar2
 ,p_dpnt_cvg_no_ctfn_rqd_flag_o    in varchar2
 ,p_dpnt_cvg_strt_dt_cd_o          in varchar2
 ,p_rt_end_dt_cd_o                 in varchar2
 ,p_rt_strt_dt_cd_o                in varchar2
 ,p_enrt_cvg_end_dt_cd_o           in varchar2
 ,p_enrt_cvg_strt_dt_cd_o          in varchar2
 ,p_dpnt_cvg_strt_dt_rl_o          in number
 ,p_dpnt_cvg_end_dt_cd_o           in varchar2
 ,p_dpnt_cvg_end_dt_rl_o           in number
 ,p_dpnt_adrs_rqd_flag_o           in varchar2
 ,p_dpnt_legv_id_rqd_flag_o        in varchar2
 ,p_susp_if_dpnt_ssn_nt_prv_cd_o   in  varchar2
 ,p_susp_if_dpnt_dob_nt_prv_cd_o   in  varchar2
 ,p_susp_if_dpnt_adr_nt_prv_cd_o   in  varchar2
 ,p_susp_if_ctfn_not_dpnt_flag_o   in  varchar2
 ,p_dpnt_ctfn_determine_cd_o       in  varchar2
 ,p_postelcn_edit_rl_o             in number
 ,p_rt_end_dt_rl_o                 in number
 ,p_rt_strt_dt_rl_o                in number
 ,p_enrt_cvg_end_dt_rl_o           in number
 ,p_enrt_cvg_strt_dt_rl_o          in number
 ,p_rqd_perd_enrt_nenrt_rl_o       in number
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_enrt_cd_o                      in varchar2
 ,p_enrt_rl_o                      in number
 ,p_dflt_enrt_cd_o                 in varchar2
 ,p_dflt_enrt_det_rl_o             in number
 ,p_drvbl_fctr_apls_rts_flag_o     in varchar2
 ,p_drvbl_fctr_prtn_elig_flag_o    in varchar2
 ,p_elig_apls_flag_o               in varchar2
 ,p_prtn_elig_ovrid_alwd_flag_o    in varchar2
 ,p_trk_inelig_per_flag_o          in varchar2
 ,p_dpnt_dob_rqd_flag_o            in varchar2
 ,p_crs_this_pl_typ_only_flag_o    in varchar2
 ,p_ptip_stat_cd_o                 in varchar2
 ,p_mx_cvg_alwd_amt_o              in number
 ,p_mx_enrd_alwd_ovrid_num_o       in number
 ,p_mn_enrd_rqd_ovrid_num_o        in number
 ,p_no_mx_pl_typ_ovrid_flag_o      in varchar2
 ,p_ordr_num_o                     in number
 ,p_prvds_cr_flag_o                in varchar2
 ,p_rqd_perd_enrt_nenrt_val_o      in number
 ,p_rqd_perd_enrt_nenrt_tm_uom_o   in varchar2
 ,p_wvbl_flag_o                    in varchar2
 ,p_drvd_fctr_dpnt_cvg_flag_o      in varchar2
 ,p_no_mn_pl_typ_overid_flag_o     in varchar2
 ,p_sbj_to_sps_lf_ins_mx_flag_o    in varchar2
 ,p_sbj_to_dpnt_lf_ins_mx_flag_o   in varchar2
 ,p_use_to_sum_ee_lf_ins_flag_o    in varchar2
 ,p_per_cvrd_cd_o                  in varchar2
 ,p_short_name_o                  in varchar2
 ,p_short_code_o                  in varchar2
  ,p_legislation_code_o                  in varchar2
  ,p_legislation_subgroup_o                  in varchar2
 ,p_vrfy_fmly_mmbr_cd_o            in varchar2
 ,p_vrfy_fmly_mmbr_rl_o            in number
 ,p_ivr_ident_o                    in varchar2
 ,p_url_ref_name_o                 in varchar2
 ,p_rqd_enrt_perd_tco_cd_o         in varchar2
 ,p_pgm_id_o                       in number
 ,p_pl_typ_id_o                    in number
 ,p_cmbn_ptip_id_o                 in number
 ,p_cmbn_ptip_opt_id_o             in number
 ,p_acrs_ptip_cvg_id_o             in number
 ,p_business_group_id_o            in number
 ,p_ctp_attribute_category_o       in varchar2
 ,p_ctp_attribute1_o               in varchar2
 ,p_ctp_attribute2_o               in varchar2
 ,p_ctp_attribute3_o               in varchar2
 ,p_ctp_attribute4_o               in varchar2
 ,p_ctp_attribute5_o               in varchar2
 ,p_ctp_attribute6_o               in varchar2
 ,p_ctp_attribute7_o               in varchar2
 ,p_ctp_attribute8_o               in varchar2
 ,p_ctp_attribute9_o               in varchar2
 ,p_ctp_attribute10_o              in varchar2
 ,p_ctp_attribute11_o              in varchar2
 ,p_ctp_attribute12_o              in varchar2
 ,p_ctp_attribute13_o              in varchar2
 ,p_ctp_attribute14_o              in varchar2
 ,p_ctp_attribute15_o              in varchar2
 ,p_ctp_attribute16_o              in varchar2
 ,p_ctp_attribute17_o              in varchar2
 ,p_ctp_attribute18_o              in varchar2
 ,p_ctp_attribute19_o              in varchar2
 ,p_ctp_attribute20_o              in varchar2
 ,p_ctp_attribute21_o              in varchar2
 ,p_ctp_attribute22_o              in varchar2
 ,p_ctp_attribute23_o              in varchar2
 ,p_ctp_attribute24_o              in varchar2
 ,p_ctp_attribute25_o              in varchar2
 ,p_ctp_attribute26_o              in varchar2
 ,p_ctp_attribute27_o              in varchar2
 ,p_ctp_attribute28_o              in varchar2
 ,p_ctp_attribute29_o              in varchar2
 ,p_ctp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ctp_rkd;

 

/
