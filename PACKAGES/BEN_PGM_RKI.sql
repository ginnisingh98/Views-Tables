--------------------------------------------------------
--  DDL for Package BEN_PGM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_RKI" AUTHID CURRENT_USER as
/* $Header: bepgmrhi.pkh 120.0 2005/05/28 10:47:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pgm_id                         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_dpnt_adrs_rqd_flag             in varchar2
 ,p_pgm_prvds_no_auto_enrt_flag    in varchar2
 ,p_dpnt_dob_rqd_flag              in varchar2
 ,p_pgm_prvds_no_dflt_enrt_flag    in varchar2
 ,p_dpnt_legv_id_rqd_flag          in varchar2
 ,p_dpnt_dsgn_lvl_cd               in varchar2
 ,p_pgm_stat_cd                    in varchar2
 ,p_ivr_ident                      in varchar2
 ,p_pgm_typ_cd                     in varchar2
 ,p_elig_apls_flag                 in varchar2
 ,p_uses_all_asmts_for_rts_flag    in varchar2
 ,p_url_ref_name                   in varchar2
 ,p_pgm_desc                       in varchar2
 ,p_prtn_elig_ovrid_alwd_flag      in varchar2
 ,p_pgm_use_all_asnts_elig_flag    in varchar2
 ,p_dpnt_dsgn_cd                   in varchar2
 ,p_mx_dpnt_pct_prtt_lf_amt        in number
 ,p_mx_sps_pct_prtt_lf_amt         in number
 ,p_acty_ref_perd_cd               in varchar2
 ,p_coord_cvg_for_all_pls_flg      in varchar2
 ,p_enrt_cvg_end_dt_cd             in varchar2
 ,p_enrt_cvg_end_dt_rl             in number
 ,p_dpnt_cvg_end_dt_cd             in varchar2
 ,p_dpnt_cvg_end_dt_rl             in number
 ,p_dpnt_cvg_strt_dt_cd            in varchar2
 ,p_dpnt_cvg_strt_dt_rl            in number
 ,p_dpnt_dsgn_no_ctfn_rqd_flag     in varchar2
 ,p_drvbl_fctr_dpnt_elig_flag      in varchar2
 ,p_drvbl_fctr_prtn_elig_flag      in varchar2
 ,p_enrt_cvg_strt_dt_cd            in varchar2
 ,p_enrt_cvg_strt_dt_rl            in number
 ,p_enrt_info_rt_freq_cd           in varchar2
 ,p_rt_strt_dt_cd                  in varchar2
 ,p_rt_strt_dt_rl                  in number
 ,p_rt_end_dt_cd                   in varchar2
 ,p_rt_end_dt_rl                   in number
 ,p_pgm_grp_cd                     in varchar2
 ,p_pgm_uom                        in varchar2
 ,p_drvbl_fctr_apls_rts_flag       in varchar2
 ,p_alws_unrstrctd_enrt_flag       in varchar2
 ,p_enrt_cd                        in varchar2
 ,p_enrt_mthd_cd                   in varchar2
 ,p_poe_lvl_cd                     in varchar2
 ,p_enrt_rl                        in number
 ,p_auto_enrt_mthd_rl              in number
 ,p_trk_inelig_per_flag            in varchar2
 ,p_business_group_id              in number
 ,p_per_cvrd_cd                    in varchar2
 ,P_vrfy_fmly_mmbr_rl              in number
 ,P_vrfy_fmly_mmbr_cd              in varchar2
 ,p_short_name			   in varchar2  /*FHR*/
 ,p_short_code			   in varchar2  /*FHR*/
  ,p_legislation_code			   in varchar2  /*FHR*/
  ,p_legislation_subgroup			   in varchar2  /*FHR*/
 ,p_Dflt_pgm_flag                  in  Varchar2
 ,p_Use_prog_points_flag           in  Varchar2
 ,p_Dflt_step_cd                   in  Varchar2
 ,p_Dflt_step_rl                   in  number
 ,p_Update_salary_cd               in  Varchar2
 ,p_Use_multi_pay_rates_flag       in  Varchar2
 ,p_dflt_element_type_id           in  number
 ,p_Dflt_input_value_id            in  number
 ,p_Use_scores_cd                  in  Varchar2
 ,p_Scores_calc_mthd_cd            in  Varchar2
 ,p_Scores_calc_rl                 in  number
 ,p_gsp_allow_override_flag         in varchar2
 ,p_use_variable_rates_flag         in varchar2
 ,p_salary_calc_mthd_cd         in varchar2
 ,p_salary_calc_mthd_rl         in number
 ,p_susp_if_dpnt_ssn_nt_prv_cd    in  varchar2
 ,p_susp_if_dpnt_dob_nt_prv_cd    in  varchar2
 ,p_susp_if_dpnt_adr_nt_prv_cd    in  varchar2
 ,p_susp_if_ctfn_not_dpnt_flag    in  varchar2
 ,p_dpnt_ctfn_determine_cd        in  varchar2
 ,p_pgm_attribute_category         in varchar2
 ,p_pgm_attribute1                 in varchar2
 ,p_pgm_attribute2                 in varchar2
 ,p_pgm_attribute3                 in varchar2
 ,p_pgm_attribute4                 in varchar2
 ,p_pgm_attribute5                 in varchar2
 ,p_pgm_attribute6                 in varchar2
 ,p_pgm_attribute7                 in varchar2
 ,p_pgm_attribute8                 in varchar2
 ,p_pgm_attribute9                 in varchar2
 ,p_pgm_attribute10                in varchar2
 ,p_pgm_attribute11                in varchar2
 ,p_pgm_attribute12                in varchar2
 ,p_pgm_attribute13                in varchar2
 ,p_pgm_attribute14                in varchar2
 ,p_pgm_attribute15                in varchar2
 ,p_pgm_attribute16                in varchar2
 ,p_pgm_attribute17                in varchar2
 ,p_pgm_attribute18                in varchar2
 ,p_pgm_attribute19                in varchar2
 ,p_pgm_attribute20                in varchar2
 ,p_pgm_attribute21                in varchar2
 ,p_pgm_attribute22                in varchar2
 ,p_pgm_attribute23                in varchar2
 ,p_pgm_attribute24                in varchar2
 ,p_pgm_attribute25                in varchar2
 ,p_pgm_attribute26                in varchar2
 ,p_pgm_attribute27                in varchar2
 ,p_pgm_attribute28                in varchar2
 ,p_pgm_attribute29                in varchar2
 ,p_pgm_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pgm_rki;

 

/
