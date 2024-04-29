--------------------------------------------------------
--  DDL for Package BEN_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_API" AUTHID CURRENT_USER as
/* $Header: beplnapi.pkh 120.0 2005/05/28 10:53:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan >------------------------|
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
--   p_alws_qdro_flag               Yes  varchar2
--   p_alws_qmcso_flag              Yes  varchar2
--   p_alws_reimbmts_flag           Yes  varchar2
--   p_bnf_addl_instn_txt_alwd_flag Yes  varchar2
--   p_bnf_adrs_rqd_flag            Yes  varchar2
--   p_bnf_cntngt_bnfs_alwd_flag    Yes  varchar2
--   p_bnf_ctfn_rqd_flag            Yes  varchar2
--   p_bnf_dob_rqd_flag             Yes  varchar2
--   p_bnf_dsge_mnr_ttee_rqd_flag   Yes  varchar2
--   p_bnf_incrmt_amt               No   number
--   p_bnf_dflt_bnf_cd              No   varchar2
--   p_bnf_legv_id_rqd_flag         Yes  varchar2
--   p_bnf_may_dsgt_org_flag        Yes  varchar2
--   p_bnf_mn_dsgntbl_amt           No   number
--   p_bnf_mn_dsgntbl_pct_val       No   number
--   p_rqd_perd_enrt_nenrt_val       No   number
--   p_ordr_num       No   number
--   p_bnf_pct_incrmt_val           No   number
--   p_bnf_pct_amt_alwd_cd          No   varchar2
--   p_bnf_qdro_rl_apls_flag        Yes  varchar2
--   p_dflt_to_asn_pndg_ctfn_cd     No   varchar2
--   p_dflt_to_asn_pndg_ctfn_rl     No   number
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_invk_dcln_prtn_pl_flag       Yes  varchar2
--   p_invk_flx_cr_pl_flag          Yes  varchar2
--   p_imptd_incm_calc_cd           no   varchar2
--   p_drvbl_dpnt_elig_flag         Yes  varchar2
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_pl_cd                        Yes  varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_ivr_ident                    No   varchar2
--   p_url_ref_name                 No   varchar2
--   p_cmpr_clms_to_cvg_or_bal_cd   No   varchar2
--   p_cobra_pymt_due_dy_num        No   number
--   p_dpnt_cvd_by_othr_apls_flag   Yes  varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_frfs_aply_flag               Yes  varchar2
--   p_hc_pl_subj_hcfa_aprvl_flag   Yes  varchar2
--   p_hghly_cmpd_rl_apls_flag      Yes  varchar2
--   p_incptn_dt                    No   date
--   p_mn_cvg_rl                    No   number
--   p_mn_cvg_rqd_amt               No   number
--   p_mn_opts_rqd_num              No   number
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_cvg_rl                    No   number
--   p_mx_opts_alwd_num             No   number
--   p_mx_cvg_wcfn_mlt_num          No   number
--   p_mx_cvg_wcfn_amt              No   number
--   p_mx_cvg_incr_alwd_amt         No   number
--   p_mx_cvg_incr_wcf_alwd_amt     No   number
--   p_mx_cvg_mlt_incr_num          No   number
--   p_mx_cvg_mlt_incr_wcf_num      No   number
--   p_mx_wtg_dt_to_use_cd          No   varchar2
--   p_mx_wtg_dt_to_use_rl          No   number
--   p_mx_wtg_perd_prte_uom         No   varchar2
--   p_mx_wtg_perd_prte_val         No   number
--   p_mx_wtg_perd_rl               No   number
--   p_nip_dflt_enrt_cd             No   varchar2
--   p_nip_dflt_enrt_det_rl         No   number
--   p_dpnt_adrs_rqd_flag           Yes  varchar2
--   p_dpnt_cvg_end_dt_cd           No   varchar2
--   p_dpnt_cvg_end_dt_rl           No   number
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   number
--   p_dpnt_dob_rqd_flag            Yes  varchar2
--   p_dpnt_leg_id_rqd_flag         Yes  varchar2
--   p_dpnt_no_ctfn_rqd_flag        Yes  varchar2
--   p_no_mn_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mn_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mn_opts_num_apls_flag     Yes  varchar2
--   p_no_mx_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mx_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mx_opts_num_apls_flag     Yes  varchar2
--   p_nip_pl_uom                   No   varchar2
--   p_rqd_perd_enrt_nenrt_uom                   No   varchar2
--   p_nip_acty_ref_perd_cd         No   varchar2
--   p_nip_enrt_info_rt_freq_cd     No   varchar2
--   p_per_cvrd_cd                  No   varchar2
--   p_enrt_cvg_end_dt_rl           No   number
--   p_postelcn_edit_rl             No   number
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_prort_prtl_yr_cvg_rstrn_cd   No   varchar2
--   p_prort_prtl_yr_cvg_rstrn_rl   No   number
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_svgs_pl_flag                 Yes  varchar2
--   p_subj_to_imptd_incm_typ_cd    Yes  varchar2
--   p_use_all_asnts_elig_flag      Yes  varchar2
--   p_use_all_asnts_for_rt_flag    Yes  varchar2
--   p_vstg_apls_flag               Yes  varchar2
--   p_wvbl_flag                    Yes  varchar2
--   p_hc_svc_typ_cd                No   varchar2
--   p_pl_stat_cd                   No   varchar2
--   p_prmry_fndg_mthd_cd           No   varchar2
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_rt_strt_dt_rl                No   number
--   p_rt_strt_dt_cd                No   varchar2
--   p_bnf_dsgn_cd                  No   varchar2
--   p_pl_typ_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pln_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pln_attribute1               No   varchar2  Descriptive Flexfield
--   p_pln_attribute2               No   varchar2  Descriptive Flexfield
--   p_pln_attribute3               No   varchar2  Descriptive Flexfield
--   p_pln_attribute4               No   varchar2  Descriptive Flexfield
--   p_pln_attribute5               No   varchar2  Descriptive Flexfield
--   p_pln_attribute6               No   varchar2  Descriptive Flexfield
--   p_pln_attribute7               No   varchar2  Descriptive Flexfield
--   p_pln_attribute8               No   varchar2  Descriptive Flexfield
--   p_pln_attribute9               No   varchar2  Descriptive Flexfield
--   p_pln_attribute10              No   varchar2  Descriptive Flexfield
--   p_pln_attribute11              No   varchar2  Descriptive Flexfield
--   p_pln_attribute12              No   varchar2  Descriptive Flexfield
--   p_pln_attribute13              No   varchar2  Descriptive Flexfield
--   p_pln_attribute14              No   varchar2  Descriptive Flexfield
--   p_pln_attribute15              No   varchar2  Descriptive Flexfield
--   p_pln_attribute16              No   varchar2  Descriptive Flexfield
--   p_pln_attribute17              No   varchar2  Descriptive Flexfield
--   p_pln_attribute18              No   varchar2  Descriptive Flexfield
--   p_pln_attribute19              No   varchar2  Descriptive Flexfield
--   p_pln_attribute20              No   varchar2  Descriptive Flexfield
--   p_pln_attribute21              No   varchar2  Descriptive Flexfield
--   p_pln_attribute22              No   varchar2  Descriptive Flexfield
--   p_pln_attribute23              No   varchar2  Descriptive Flexfield
--   p_pln_attribute24              No   varchar2  Descriptive Flexfield
--   p_pln_attribute25              No   varchar2  Descriptive Flexfield
--   p_pln_attribute26              No   varchar2  Descriptive Flexfield
--   p_pln_attribute27              No   varchar2  Descriptive Flexfield
--   p_pln_attribute28              No   varchar2  Descriptive Flexfield
--   p_pln_attribute29              No   varchar2  Descriptive Flexfield
--   p_pln_attribute30              No   varchar2  Descriptive Flexfield
--   p_actl_prem_id                 No   number
--   p_effective_date                Yes  date      Session Date.
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   number
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_pl_id                        Yes  number    PK of record
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
procedure create_Plan
(
   p_validate                       in boolean    default false
  ,p_pl_id                          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_alws_qdro_flag                 in  varchar2  default 'N'
  ,p_alws_qmcso_flag                in  varchar2  default 'N'
  ,p_alws_reimbmts_flag             in  varchar2  default 'N'
  ,p_bnf_addl_instn_txt_alwd_flag   in  varchar2  default 'N'
  ,p_bnf_adrs_rqd_flag              in  varchar2  default 'N'
  ,p_bnf_cntngt_bnfs_alwd_flag      in  varchar2  default 'N'
  ,p_bnf_ctfn_rqd_flag              in  varchar2  default 'N'
  ,p_bnf_dob_rqd_flag               in  varchar2  default 'N'
  ,p_bnf_dsge_mnr_ttee_rqd_flag     in  varchar2  default 'N'
  ,p_bnf_incrmt_amt                 in  number    default null
  ,p_bnf_dflt_bnf_cd                in  varchar2  default null
  ,p_bnf_legv_id_rqd_flag           in  varchar2  default 'N'
  ,p_bnf_may_dsgt_org_flag          in  varchar2  default 'N'
  ,p_bnf_mn_dsgntbl_amt             in  number    default null
  ,p_bnf_mn_dsgntbl_pct_val         in  number    default null
  ,p_rqd_perd_enrt_nenrt_val         in  number    default null
  ,p_ordr_num         in  number    default null
  ,p_bnf_pct_incrmt_val             in  number    default null
  ,p_bnf_pct_amt_alwd_cd            in  varchar2  default null
  ,p_bnf_qdro_rl_apls_flag          in  varchar2  default 'N'
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default null
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default null
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default 'N'
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default 'N'
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_elig_apls_flag                 in  varchar2  default 'N'
  ,p_invk_dcln_prtn_pl_flag         in  varchar2  default 'N'
  ,p_invk_flx_cr_pl_flag            in  varchar2  default 'N'
  ,p_imptd_incm_calc_cd             in  varchar2  default null
  ,p_drvbl_dpnt_elig_flag           in  varchar2  default 'N'
  ,p_trk_inelig_per_flag            in  varchar2  default 'N'
  ,p_pl_cd                          in  varchar2  default null
  ,p_auto_enrt_mthd_rl              in  number    default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_url_ref_name                   in  varchar2  default null
  ,p_cmpr_clms_to_cvg_or_bal_cd     in  varchar2  default null
  ,p_cobra_pymt_due_dy_num          in  number    default null
  ,p_dpnt_cvd_by_othr_apls_flag     in  varchar2  default 'N'
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_enrt_cd                        in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_frfs_aply_flag                 in  varchar2  default 'N'
  ,p_hc_pl_subj_hcfa_aprvl_flag     in  varchar2  default 'N'
  ,p_hghly_cmpd_rl_apls_flag        in  varchar2  default 'N'
  ,p_incptn_dt                      in  date      default null
  ,p_mn_cvg_rl                      in  number    default null
  ,p_mn_cvg_rqd_amt                 in  number    default null
  ,p_mn_opts_rqd_num                in  number    default null
  ,p_mx_cvg_alwd_amt                in  number    default null
  ,p_mx_cvg_rl                      in  number    default null
  ,p_mx_opts_alwd_num               in  number    default null
  ,p_mx_cvg_wcfn_mlt_num            in  number    default null
  ,p_mx_cvg_wcfn_amt                in  number    default null
  ,p_mx_cvg_incr_alwd_amt           in  number    default null
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default null
  ,p_mx_cvg_mlt_incr_num            in  number    default null
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default null
  ,p_mx_wtg_dt_to_use_cd            in  varchar2  default null
  ,p_mx_wtg_dt_to_use_rl            in  number    default null
  ,p_mx_wtg_perd_prte_uom           in  varchar2  default null
  ,p_mx_wtg_perd_prte_val           in  number    default null
  ,p_mx_wtg_perd_rl                 in  number    default null
  ,p_nip_dflt_enrt_cd               in  varchar2  default null
  ,p_nip_dflt_enrt_det_rl           in  number    default null
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default 'N'
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default null
  ,p_dpnt_cvg_end_dt_rl             in  number    default null
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  number    default null
  ,p_dpnt_dob_rqd_flag              in  varchar2  default 'N'
  ,p_dpnt_leg_id_rqd_flag           in  varchar2  default 'N'
  ,p_dpnt_no_ctfn_rqd_flag          in  varchar2  default 'N'
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2  default 'N'
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default 'N'
  ,p_no_mn_opts_num_apls_flag       in  varchar2  default 'N'
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default 'N'
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default 'N'
  ,p_no_mx_opts_num_apls_flag       in  varchar2  default 'N'
  ,p_nip_pl_uom                     in  varchar2  default null
  ,p_rqd_perd_enrt_nenrt_uom                     in  varchar2  default null
  ,p_nip_acty_ref_perd_cd           in  varchar2  default null
  ,p_nip_enrt_info_rt_freq_cd       in  varchar2  default null
  ,p_per_cvrd_cd                    in  varchar2  default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_postelcn_edit_rl               in  number    default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2  default null
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number    default null
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default 'N'
  ,p_svgs_pl_flag                   in  varchar2  default 'N'
  ,p_subj_to_imptd_incm_typ_cd      in  varchar2  default null
  ,p_use_all_asnts_elig_flag        in  varchar2  default 'N'
  ,p_use_all_asnts_for_rt_flag      in  varchar2  default 'N'
  ,p_vstg_apls_flag                 in  varchar2  default 'N'
  ,p_wvbl_flag                      in  varchar2  default 'N'
  ,p_hc_svc_typ_cd                  in  varchar2  default null
  ,p_pl_stat_cd                     in  varchar2  default null
  ,p_prmry_fndg_mthd_cd             in  varchar2  default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_bnf_dsgn_cd                    in  varchar2  default null
  ,p_pl_typ_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_enrt_pl_opt_flag               in  varchar2  default 'N'
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_MAY_ENRL_PL_N_OIPL_FLAG        in  VARCHAR2  default 'N'
  ,p_ENRT_RL                        in  NUMBER    default null
  ,p_rqd_perd_enrt_nenrt_rl                        in  NUMBER    default null
  ,p_ALWS_UNRSTRCTD_ENRT_FLAG       in  VARCHAR2  default 'N'
  ,p_BNFT_OR_OPTION_RSTRCTN_CD      in  VARCHAR2  default null
  ,p_CVG_INCR_R_DECR_ONLY_CD        in  VARCHAR2  default null
  ,p_unsspnd_enrt_cd                in  varchar2  default null
  ,p_pln_attribute_category         in  varchar2  default null
  ,p_pln_attribute1                 in  varchar2  default null
  ,p_pln_attribute2                 in  varchar2  default null
  ,p_pln_attribute3                 in  varchar2  default null
  ,p_pln_attribute4                 in  varchar2  default null
  ,p_pln_attribute5                 in  varchar2  default null
  ,p_pln_attribute6                 in  varchar2  default null
  ,p_pln_attribute7                 in  varchar2  default null
  ,p_pln_attribute8                 in  varchar2  default null
  ,p_pln_attribute9                 in  varchar2  default null
  ,p_pln_attribute10                in  varchar2  default null
  ,p_pln_attribute11                in  varchar2  default null
  ,p_pln_attribute12                in  varchar2  default null
  ,p_pln_attribute13                in  varchar2  default null
  ,p_pln_attribute14                in  varchar2  default null
  ,p_pln_attribute15                in  varchar2  default null
  ,p_pln_attribute16                in  varchar2  default null
  ,p_pln_attribute17                in  varchar2  default null
  ,p_pln_attribute18                in  varchar2  default null
  ,p_pln_attribute19                in  varchar2  default null
  ,p_pln_attribute20                in  varchar2  default null
  ,p_pln_attribute21                in  varchar2  default null
  ,p_pln_attribute22                in  varchar2  default null
  ,p_pln_attribute23                in  varchar2  default null
  ,p_pln_attribute24                in  varchar2  default null
  ,p_pln_attribute25                in  varchar2  default null
  ,p_pln_attribute26                in  varchar2  default null
  ,p_pln_attribute27                in  varchar2  default null
  ,p_pln_attribute28                in  varchar2  default null
  ,p_pln_attribute29                in  varchar2  default null
  ,p_pln_attribute30                in  varchar2  default null
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default 'Y'
  ,p_ctfn_determine_cd              in  varchar2  default null
  ,p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2  default null
  ,p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2  default null
  ,p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2  default null
  ,p_susp_if_ctfn_not_dpnt_flag     in  varchar2  default 'Y'
  ,p_susp_if_bnf_ssn_nt_prv_cd      in  varchar2  default null
  ,p_susp_if_bnf_dob_nt_prv_cd      in  varchar2  default null
  ,p_susp_if_bnf_adr_nt_prv_cd      in  varchar2  default null
  ,p_susp_if_ctfn_not_bnf_flag      in  varchar2  default 'Y'
  ,p_dpnt_ctfn_determine_cd         in  varchar2  default null
  ,p_bnf_ctfn_determine_cd          in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_actl_prem_id                   in  number    default null
  ,p_effective_date                 in  date
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default null
  ,p_vrfy_fmly_mmbr_rl              in  number    default null
  ,p_alws_tmpry_id_crd_flag         in  varchar2  default 'N'
  ,p_nip_dflt_flag                  in  varchar2  default 'N'
  -- Forfeiture process
  ,p_frfs_distr_mthd_cd             in  varchar2  default null
  ,p_frfs_distr_mthd_rl             in  number    default null
  ,p_frfs_cntr_det_cd               in  varchar2  default null
  ,p_frfs_distr_det_cd              in  varchar2  default null
  ,p_cost_alloc_keyflex_1_id        in  number    default null
  ,p_cost_alloc_keyflex_2_id        in  number    default null
  ,p_post_to_gl_flag                in  varchar2  default 'N'
  ,p_frfs_val_det_cd                in  varchar2  default null
  ,p_frfs_mx_cryfwd_val             in  number    default null
  ,p_frfs_portion_det_cd            in  varchar2  default null
  ,p_bndry_perd_cd                  in  varchar2  default null
  ,p_short_name			    in  varchar2  default null
  ,p_short_code			    in  varchar2  default null
  ,p_legislation_code		    in  varchar2  default null
  ,p_legislation_subgroup	    in  varchar2  default null
  ,p_group_pl_id                    in  number  default null
  ,p_mapping_table_name             in  varchar2  default null
  ,p_mapping_table_pk_id            in  number    default null
  ,p_function_code                  in  varchar2  default null
  ,p_pl_yr_not_applcbl_flag         in  varchar2  default 'N'
  ,p_use_csd_rsd_prccng_cd          in  varchar2  default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan >------------------------|
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
--   p_pl_id                        Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_alws_qdro_flag               Yes  varchar2
--   p_alws_qmcso_flag              Yes  varchar2
--   p_alws_reimbmts_flag           Yes  varchar2
--   p_bnf_addl_instn_txt_alwd_flag Yes  varchar2
--   p_bnf_adrs_rqd_flag            Yes  varchar2
--   p_bnf_cntngt_bnfs_alwd_flag    Yes  varchar2
--   p_bnf_ctfn_rqd_flag            Yes  varchar2
--   p_bnf_dob_rqd_flag             Yes  varchar2
--   p_bnf_dsge_mnr_ttee_rqd_flag   Yes  varchar2
--   p_bnf_incrmt_amt               No   number
--   p_bnf_dflt_bnf_cd              No   varchar2
--   p_bnf_legv_id_rqd_flag         Yes  varchar2
--   p_bnf_may_dsgt_org_flag        Yes  varchar2
--   p_bnf_mn_dsgntbl_amt           No   number
--   p_bnf_mn_dsgntbl_pct_val       No   number
--   p_rqd_perd_enrt_nenrt_val       No   number
--   p_ordr_num       No   number
--   p_bnf_pct_incrmt_val           No   number
--   p_bnf_pct_amt_alwd_cd          No   varchar2
--   p_bnf_qdro_rl_apls_flag        Yes  varchar2
--   p_dflt_to_asn_pndg_ctfn_cd     No   varchar2
--   p_dflt_to_asn_pndg_ctfn_rl     No   number
--   p_drvbl_fctr_apls_rts_flag     Yes  varchar2
--   p_drvbl_fctr_prtn_elig_flag    Yes  varchar2
--   p_dpnt_dsgn_cd                 No   varchar2
--   p_elig_apls_flag               Yes  varchar2
--   p_invk_dcln_prtn_pl_flag       Yes  varchar2
--   p_invk_flx_cr_pl_flag          Yes  varchar2
--   p_imptd_incm_calc_cd           No   varchar2
--   p_drvbl_dpnt_elig_flag         Yes  varchar2
--   p_trk_inelig_per_flag          Yes  varchar2
--   p_pl_cd                        Yes  varchar2
--   p_auto_enrt_mthd_rl            No   number
--   p_ivr_ident                    No   varchar2
--   p_url_ref_name                 No   varchar2
--   p_cmpr_clms_to_cvg_or_bal_cd   No   varchar2
--   p_cobra_pymt_due_dy_num        No   number
--   p_dpnt_cvd_by_othr_apls_flag   Yes  varchar2
--   p_enrt_mthd_cd                 No   varchar2
--   p_enrt_cd                      No   varchar2
--   p_enrt_cvg_strt_dt_cd          No   varchar2
--   p_enrt_cvg_end_dt_cd           No   varchar2
--   p_frfs_aply_flag               Yes  varchar2
--   p_hc_pl_subj_hcfa_aprvl_flag   Yes  varchar2
--   p_hghly_cmpd_rl_apls_flag      Yes  varchar2
--   p_incptn_dt                    No   date
--   p_mn_cvg_rl                    No   number
--   p_mn_cvg_rqd_amt               No   number
--   p_mn_opts_rqd_num              No   number
--   p_mx_cvg_alwd_amt              No   number
--   p_mx_cvg_rl                    No   number
--   p_mx_opts_alwd_num             No   number
--   p_mx_cvg_wcfn_mlt_num          No   number
--   p_mx_cvg_wcfn_amt              No   number
--   p_mx_cvg_incr_alwd_amt         No   number
--   p_mx_cvg_incr_wcf_alwd_amt     No   number
--   p_mx_cvg_mlt_incr_num          No   number
--   p_mx_cvg_mlt_incr_wcf_num      No   number
--   p_mx_wtg_dt_to_use_cd          No   varchar2
--   p_mx_wtg_dt_to_use_rl          No   number
--   p_mx_wtg_perd_prte_uom         No   varchar2
--   p_mx_wtg_perd_prte_val         No   number
--   p_mx_wtg_perd_rl               No   number
--   p_nip_dflt_enrt_cd             No   varchar2
--   p_nip_dflt_enrt_det_rl         No   number
--   p_dpnt_adrs_rqd_flag           Yes  varchar2
--   p_dpnt_cvg_end_dt_cd           No   varchar2
--   p_dpnt_cvg_end_dt_rl           No   number
--   p_dpnt_cvg_strt_dt_cd          No   varchar2
--   p_dpnt_cvg_strt_dt_rl          No   number
--   p_dpnt_dob_rqd_flag            Yes  varchar2
--   p_dpnt_leg_id_rqd_flag         Yes  varchar2
--   p_dpnt_no_ctfn_rqd_flag        Yes  varchar2
--   p_no_mn_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mn_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mn_opts_num_apls_flag     Yes  varchar2
--   p_no_mx_cvg_amt_apls_flag      Yes  varchar2
--   p_no_mx_cvg_incr_apls_flag     Yes  varchar2
--   p_no_mx_opts_num_apls_flag     Yes  varchar2
--   p_nip_pl_uom                   No   varchar2
--   p_rqd_perd_enrt_nenrt_uom                   No   varchar2
--   p_nip_acty_ref_perd_cd         No   varchar2
--   p_nip_enrt_info_rt_freq_cd     No   varchar2
--   p_per_cvrd_cd                  No   varchar2
--   p_enrt_cvg_end_dt_rl           No   number
--   p_postelcn_edit_rl             No   number
--   p_enrt_cvg_strt_dt_rl          No   number
--   p_prort_prtl_yr_cvg_rstrn_cd   No   varchar2
--   p_prort_prtl_yr_cvg_rstrn_rl   No   number
--   p_prtn_elig_ovrid_alwd_flag    Yes  varchar2
--   p_svgs_pl_flag                 Yes  varchar2
--   p_subj_to_imptd_incm_typ_cd    Yes  varchar2
--   p_use_all_asnts_elig_flag      Yes  varchar2
--   p_use_all_asnts_for_rt_flag    Yes  varchar2
--   p_vstg_apls_flag               Yes  varchar2
--   p_wvbl_flag                    Yes  varchar2
--   p_hc_svc_typ_cd                No   varchar2
--   p_pl_stat_cd                   No   varchar2
--   p_prmry_fndg_mthd_cd           No   varchar2
--   p_rt_end_dt_cd                 No   varchar2
--   p_rt_end_dt_rl                 No   number
--   p_rt_strt_dt_rl                No   number
--   p_rt_strt_dt_cd                No   varchar2
--   p_bnf_dsgn_cd                  No   varchar2
--   p_pl_typ_id                    Yes  number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pln_attribute_category       No   varchar2  Descriptive Flexfield
--   p_pln_attribute1               No   varchar2  Descriptive Flexfield
--   p_pln_attribute2               No   varchar2  Descriptive Flexfield
--   p_pln_attribute3               No   varchar2  Descriptive Flexfield
--   p_pln_attribute4               No   varchar2  Descriptive Flexfield
--   p_pln_attribute5               No   varchar2  Descriptive Flexfield
--   p_pln_attribute6               No   varchar2  Descriptive Flexfield
--   p_pln_attribute7               No   varchar2  Descriptive Flexfield
--   p_pln_attribute8               No   varchar2  Descriptive Flexfield
--   p_pln_attribute9               No   varchar2  Descriptive Flexfield
--   p_pln_attribute10              No   varchar2  Descriptive Flexfield
--   p_pln_attribute11              No   varchar2  Descriptive Flexfield
--   p_pln_attribute12              No   varchar2  Descriptive Flexfield
--   p_pln_attribute13              No   varchar2  Descriptive Flexfield
--   p_pln_attribute14              No   varchar2  Descriptive Flexfield
--   p_pln_attribute15              No   varchar2  Descriptive Flexfield
--   p_pln_attribute16              No   varchar2  Descriptive Flexfield
--   p_pln_attribute17              No   varchar2  Descriptive Flexfield
--   p_pln_attribute18              No   varchar2  Descriptive Flexfield
--   p_pln_attribute19              No   varchar2  Descriptive Flexfield
--   p_pln_attribute20              No   varchar2  Descriptive Flexfield
--   p_pln_attribute21              No   varchar2  Descriptive Flexfield
--   p_pln_attribute22              No   varchar2  Descriptive Flexfield
--   p_pln_attribute23              No   varchar2  Descriptive Flexfield
--   p_pln_attribute24              No   varchar2  Descriptive Flexfield
--   p_pln_attribute25              No   varchar2  Descriptive Flexfield
--   p_pln_attribute26              No   varchar2  Descriptive Flexfield
--   p_pln_attribute27              No   varchar2  Descriptive Flexfield
--   p_pln_attribute28              No   varchar2  Descriptive Flexfield
--   p_pln_attribute29              No   varchar2  Descriptive Flexfield
--   p_pln_attribute30              No   varchar2  Descriptive Flexfield
--   p_actl_prem_id                 No   number
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--   p_vrfy_fmly_mmbr_cd            No   varchar2
--   p_vrfy_fmly_mmbr_rl            No   number
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
procedure update_Plan
  (
   p_validate                       in boolean    default false
  ,p_pl_id                          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_alws_qdro_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_alws_qmcso_flag                in  varchar2  default hr_api.g_varchar2
  ,p_alws_reimbmts_flag             in  varchar2  default hr_api.g_varchar2
  ,p_bnf_addl_instn_txt_alwd_flag   in  varchar2  default hr_api.g_varchar2
  ,p_bnf_adrs_rqd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_bnf_cntngt_bnfs_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_bnf_ctfn_rqd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_bnf_dob_rqd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_bnf_dsge_mnr_ttee_rqd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_bnf_incrmt_amt                 in  number    default hr_api.g_number
  ,p_bnf_dflt_bnf_cd                in  varchar2  default hr_api.g_varchar2
  ,p_bnf_legv_id_rqd_flag           in  varchar2  default hr_api.g_varchar2
  ,p_bnf_may_dsgt_org_flag          in  varchar2  default hr_api.g_varchar2
  ,p_bnf_mn_dsgntbl_amt             in  number    default hr_api.g_number
  ,p_bnf_mn_dsgntbl_pct_val         in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_val         in  number    default hr_api.g_number
  ,p_ordr_num         in  number    default hr_api.g_number
  ,p_bnf_pct_incrmt_val             in  number    default hr_api.g_number
  ,p_bnf_pct_amt_alwd_cd            in  varchar2  default hr_api.g_varchar2
  ,p_bnf_qdro_rl_apls_flag          in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_cd       in  varchar2  default hr_api.g_varchar2
  ,p_dflt_to_asn_pndg_ctfn_rl       in  number    default hr_api.g_number
  ,p_drvbl_fctr_apls_rts_flag       in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_fctr_prtn_elig_flag      in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_elig_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_invk_dcln_prtn_pl_flag         in  varchar2  default hr_api.g_varchar2
  ,p_invk_flx_cr_pl_flag            in  varchar2  default hr_api.g_varchar2
  ,p_imptd_incm_calc_cd             in  varchar2  default hr_api.g_varchar2
  ,p_drvbl_dpnt_elig_flag           in  varchar2  default hr_api.g_varchar2
  ,p_trk_inelig_per_flag            in  varchar2  default hr_api.g_varchar2
  ,p_pl_cd                          in  varchar2  default hr_api.g_varchar2
  ,p_auto_enrt_mthd_rl              in  number    default hr_api.g_number
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_url_ref_name                   in  varchar2  default hr_api.g_varchar2
  ,p_cmpr_clms_to_cvg_or_bal_cd     in  varchar2  default hr_api.g_varchar2
  ,p_cobra_pymt_due_dy_num          in  number    default hr_api.g_number
  ,p_dpnt_cvd_by_othr_apls_flag     in  varchar2  default hr_api.g_varchar2
  ,p_enrt_mthd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_frfs_aply_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_hc_pl_subj_hcfa_aprvl_flag     in  varchar2  default hr_api.g_varchar2
  ,p_hghly_cmpd_rl_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_incptn_dt                      in  date      default hr_api.g_date
  ,p_mn_cvg_rl                      in  number    default hr_api.g_number
  ,p_mn_cvg_rqd_amt                 in  number    default hr_api.g_number
  ,p_mn_opts_rqd_num                in  number    default hr_api.g_number
  ,p_mx_cvg_alwd_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_rl                      in  number    default hr_api.g_number
  ,p_mx_opts_alwd_num               in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_mlt_num            in  number    default hr_api.g_number
  ,p_mx_cvg_wcfn_amt                in  number    default hr_api.g_number
  ,p_mx_cvg_incr_alwd_amt           in  number    default hr_api.g_number
  ,p_mx_cvg_incr_wcf_alwd_amt       in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_num            in  number    default hr_api.g_number
  ,p_mx_cvg_mlt_incr_wcf_num        in  number    default hr_api.g_number
  ,p_mx_wtg_dt_to_use_cd            in  varchar2  default hr_api.g_varchar2
  ,p_mx_wtg_dt_to_use_rl            in  number    default hr_api.g_number
  ,p_mx_wtg_perd_prte_uom           in  varchar2  default hr_api.g_varchar2
  ,p_mx_wtg_perd_prte_val           in  number    default hr_api.g_number
  ,p_mx_wtg_perd_rl                 in  number    default hr_api.g_number
  ,p_nip_dflt_enrt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_nip_dflt_enrt_det_rl           in  number    default hr_api.g_number
  ,p_dpnt_adrs_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_dpnt_dob_rqd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_leg_id_rqd_flag           in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_no_ctfn_rqd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_opts_num_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_amt_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_cvg_incr_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_opts_num_apls_flag       in  varchar2  default hr_api.g_varchar2
  ,p_nip_pl_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_rqd_perd_enrt_nenrt_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_nip_acty_ref_perd_cd           in  varchar2  default hr_api.g_varchar2
  ,p_nip_enrt_info_rt_freq_cd       in  varchar2  default hr_api.g_varchar2
  ,p_per_cvrd_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_postelcn_edit_rl               in  number    default hr_api.g_number
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_prort_prtl_yr_cvg_rstrn_cd     in  varchar2  default hr_api.g_varchar2
  ,p_prort_prtl_yr_cvg_rstrn_rl     in  number    default hr_api.g_number
  ,p_prtn_elig_ovrid_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_svgs_pl_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_subj_to_imptd_incm_typ_cd      in  varchar2  default hr_api.g_varchar2
  ,p_use_all_asnts_elig_flag        in  varchar2  default hr_api.g_varchar2
  ,p_use_all_asnts_for_rt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_vstg_apls_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_wvbl_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_hc_svc_typ_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_pl_stat_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_prmry_fndg_mthd_cd             in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_bnf_dsgn_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_enrt_pl_opt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_MAY_ENRL_PL_N_OIPL_FLAG        in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_ENRT_RL                        in  NUMBER    default hr_api.g_NUMBER
  ,p_rqd_perd_enrt_nenrt_rl         in  NUMBER    default hr_api.g_NUMBER
  ,p_ALWS_UNRSTRCTD_ENRT_FLAG       in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_BNFT_OR_OPTION_RSTRCTN_CD      in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_CVG_INCR_R_DECR_ONLY_CD        in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_unsspnd_enrt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pln_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_determine_cd              in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_dpnt_flag     in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_bnf_ssn_nt_prv_cd      in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_bnf_dob_nt_prv_cd      in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_bnf_adr_nt_prv_cd      in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_bnf_flag      in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_ctfn_determine_cd         in  varchar2  default hr_api.g_varchar2
  ,p_bnf_ctfn_determine_cd          in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_vrfy_fmly_mmbr_cd              in  varchar2  default hr_api.g_varchar2
  ,p_vrfy_fmly_mmbr_rl              in  number    default hr_api.g_number
  ,p_alws_tmpry_id_crd_flag         in  varchar2  default hr_api.g_varchar2
  ,p_nip_dflt_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_frfs_distr_mthd_cd             in  varchar2  default hr_api.g_varchar2
  ,p_frfs_distr_mthd_rl             in  number    default hr_api.g_number
  ,p_frfs_cntr_det_cd               in  varchar2  default hr_api.g_varchar2
  ,p_frfs_distr_det_cd              in  varchar2  default hr_api.g_varchar2
  ,p_cost_alloc_keyflex_1_id        in  number    default hr_api.g_number
  ,p_cost_alloc_keyflex_2_id        in  number    default hr_api.g_number
  ,p_post_to_gl_flag                in  varchar2  default hr_api.g_varchar2
  ,p_frfs_val_det_cd                in  varchar2  default hr_api.g_varchar2
  ,p_frfs_mx_cryfwd_val             in  number    default hr_api.g_number
  ,p_frfs_portion_det_cd            in  varchar2  default hr_api.g_varchar2
  ,p_bndry_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_short_code		            in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code	            in  varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup	    in  varchar2  default hr_api.g_varchar2
  ,p_group_pl_id	            in  number  default hr_api.g_number
  ,p_mapping_table_name             in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_pk_id            in  number    default hr_api.g_number
  ,p_function_code                  in  varchar2  default hr_api.g_varchar2
  ,p_pl_yr_not_applcbl_flag         in  varchar2  default hr_api.g_varchar2
  ,p_use_csd_rsd_prccng_cd          in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan >------------------------|
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
--   p_pl_id                        Yes  number    PK of record
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
procedure delete_Plan
  (
   p_validate                       in boolean        default false
  ,p_pl_id                          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
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
--   p_pl_id                 Yes  number   PK of record
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
  (
    p_pl_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_Plan_api;

 

/
