--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_API" as
/* $Header: beplnapi.pkb 120.0 2005/05/28 10:53:17 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Plan_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan >----------------------|
-- ----------------------------------------------------------------------------
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
  ,p_rqd_perd_enrt_nenrt_val        in  number    default null
  ,p_ordr_num                       in  number    default null
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
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2  default null
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
  ,p_may_enrl_pl_n_oipl_flag        in  varchar2  default 'N'
  ,p_enrt_rl                        in  number    default null
  ,p_rqd_perd_enrt_nenrt_rl         in  number    default null
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default 'N'
  ,p_bnft_or_option_rstrctn_cd      in  varchar2  default null
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default null
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
  ,p_group_pl_id		    in  number    default null
  ,p_mapping_table_name             in  varchar2  default null
  ,p_mapping_table_pk_id            in  number    default null
  ,p_function_code                  in  varchar2  default null
  ,p_pl_yr_not_applcbl_flag         in  varchar2  default 'N'
  ,p_use_csd_rsd_prccng_cd         in  varchar2  default  null
 ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_id ben_pl_f.pl_id%TYPE;
  l_effective_start_date ben_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Plan';
  l_object_version_number ben_pl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Plan;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Plan
    --
    ben_Plan_bk1.create_Plan_b
      (
       p_name                           =>  p_name
      ,p_alws_qdro_flag                 =>  p_alws_qdro_flag
      ,p_alws_qmcso_flag                =>  p_alws_qmcso_flag
      ,p_alws_reimbmts_flag             =>  p_alws_reimbmts_flag
      ,p_bnf_addl_instn_txt_alwd_flag   =>  p_bnf_addl_instn_txt_alwd_flag
      ,p_bnf_adrs_rqd_flag              =>  p_bnf_adrs_rqd_flag
      ,p_bnf_cntngt_bnfs_alwd_flag      =>  p_bnf_cntngt_bnfs_alwd_flag
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_bnf_dob_rqd_flag               =>  p_bnf_dob_rqd_flag
      ,p_bnf_dsge_mnr_ttee_rqd_flag     =>  p_bnf_dsge_mnr_ttee_rqd_flag
      ,p_bnf_incrmt_amt                 =>  p_bnf_incrmt_amt
      ,p_bnf_dflt_bnf_cd                =>  p_bnf_dflt_bnf_cd
      ,p_bnf_legv_id_rqd_flag           =>  p_bnf_legv_id_rqd_flag
      ,p_bnf_may_dsgt_org_flag          =>  p_bnf_may_dsgt_org_flag
      ,p_bnf_mn_dsgntbl_amt             =>  p_bnf_mn_dsgntbl_amt
      ,p_bnf_mn_dsgntbl_pct_val         =>  p_bnf_mn_dsgntbl_pct_val
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_bnf_pct_incrmt_val             =>  p_bnf_pct_incrmt_val
      ,p_bnf_pct_amt_alwd_cd            =>  p_bnf_pct_amt_alwd_cd
      ,p_bnf_qdro_rl_apls_flag          =>  p_bnf_qdro_rl_apls_flag
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_invk_dcln_prtn_pl_flag         =>  p_invk_dcln_prtn_pl_flag
      ,p_invk_flx_cr_pl_flag            =>  p_invk_flx_cr_pl_flag
      ,p_imptd_incm_calc_cd             =>  p_imptd_incm_calc_cd
      ,p_drvbl_dpnt_elig_flag           =>  p_drvbl_dpnt_elig_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_pl_cd                          =>  p_pl_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_cmpr_clms_to_cvg_or_bal_cd     =>  p_cmpr_clms_to_cvg_or_bal_cd
      ,p_cobra_pymt_due_dy_num          =>  p_cobra_pymt_due_dy_num
      ,p_dpnt_cvd_by_othr_apls_flag     =>  p_dpnt_cvd_by_othr_apls_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_frfs_aply_flag                 =>  p_frfs_aply_flag
      ,p_hc_pl_subj_hcfa_aprvl_flag     =>  p_hc_pl_subj_hcfa_aprvl_flag
      ,p_hghly_cmpd_rl_apls_flag        =>  p_hghly_cmpd_rl_apls_flag
      ,p_incptn_dt                      =>  p_incptn_dt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mn_cvg_rqd_amt                 =>  p_mn_cvg_rqd_amt
      ,p_mn_opts_rqd_num                =>  p_mn_opts_rqd_num
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_opts_alwd_num               =>  p_mx_opts_alwd_num
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_wtg_dt_to_use_cd            =>  p_mx_wtg_dt_to_use_cd
      ,p_mx_wtg_dt_to_use_rl            =>  p_mx_wtg_dt_to_use_rl
      ,p_mx_wtg_perd_prte_uom           =>  p_mx_wtg_perd_prte_uom
      ,p_mx_wtg_perd_prte_val           =>  p_mx_wtg_perd_prte_val
      ,p_mx_wtg_perd_rl                 =>  p_mx_wtg_perd_rl
      ,p_nip_dflt_enrt_cd               =>  p_nip_dflt_enrt_cd
      ,p_nip_dflt_enrt_det_rl           =>  p_nip_dflt_enrt_det_rl
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_dpnt_leg_id_rqd_flag           =>  p_dpnt_leg_id_rqd_flag
      ,p_dpnt_no_ctfn_rqd_flag          =>  p_dpnt_no_ctfn_rqd_flag
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mn_opts_num_apls_flag       =>  p_no_mn_opts_num_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_no_mx_opts_num_apls_flag       =>  p_no_mx_opts_num_apls_flag
      ,p_nip_pl_uom                     =>  p_nip_pl_uom
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_nip_acty_ref_perd_cd           =>  p_nip_acty_ref_perd_cd
      ,p_nip_enrt_info_rt_freq_cd       =>  p_nip_enrt_info_rt_freq_cd
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_svgs_pl_flag                   =>  p_svgs_pl_flag
      ,p_subj_to_imptd_incm_typ_cd      =>  p_subj_to_imptd_incm_typ_cd
      ,p_use_all_asnts_elig_flag        =>  p_use_all_asnts_elig_flag
      ,p_use_all_asnts_for_rt_flag      =>  p_use_all_asnts_for_rt_flag
      ,p_vstg_apls_flag                 =>  p_vstg_apls_flag
      ,p_wvbl_flag                      =>  p_wvbl_flag
      ,p_hc_svc_typ_cd                  =>  p_hc_svc_typ_cd
      ,p_pl_stat_cd                     =>  p_pl_stat_cd
      ,p_prmry_fndg_mthd_cd             =>  p_prmry_fndg_mthd_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_bnf_dsgn_cd                    =>  p_bnf_dsgn_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_pl_opt_flag               =>  p_enrt_pl_opt_flag
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_may_enrl_pl_n_oipl_flag        =>  p_may_enrl_pl_n_oipl_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_pln_attribute_category         =>  p_pln_attribute_category
      ,p_pln_attribute1                 =>  p_pln_attribute1
      ,p_pln_attribute2                 =>  p_pln_attribute2
      ,p_pln_attribute3                 =>  p_pln_attribute3
      ,p_pln_attribute4                 =>  p_pln_attribute4
      ,p_pln_attribute5                 =>  p_pln_attribute5
      ,p_pln_attribute6                 =>  p_pln_attribute6
      ,p_pln_attribute7                 =>  p_pln_attribute7
      ,p_pln_attribute8                 =>  p_pln_attribute8
      ,p_pln_attribute9                 =>  p_pln_attribute9
      ,p_pln_attribute10                =>  p_pln_attribute10
      ,p_pln_attribute11                =>  p_pln_attribute11
      ,p_pln_attribute12                =>  p_pln_attribute12
      ,p_pln_attribute13                =>  p_pln_attribute13
      ,p_pln_attribute14                =>  p_pln_attribute14
      ,p_pln_attribute15                =>  p_pln_attribute15
      ,p_pln_attribute16                =>  p_pln_attribute16
      ,p_pln_attribute17                =>  p_pln_attribute17
      ,p_pln_attribute18                =>  p_pln_attribute18
      ,p_pln_attribute19                =>  p_pln_attribute19
      ,p_pln_attribute20                =>  p_pln_attribute20
      ,p_pln_attribute21                =>  p_pln_attribute21
      ,p_pln_attribute22                =>  p_pln_attribute22
      ,p_pln_attribute23                =>  p_pln_attribute23
      ,p_pln_attribute24                =>  p_pln_attribute24
      ,p_pln_attribute25                =>  p_pln_attribute25
      ,p_pln_attribute26                =>  p_pln_attribute26
      ,p_pln_attribute27                =>  p_pln_attribute27
      ,p_pln_attribute28                =>  p_pln_attribute28
      ,p_pln_attribute29                =>  p_pln_attribute29
      ,p_pln_attribute30                =>  p_pln_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_susp_if_bnf_ssn_nt_prv_cd      =>  p_susp_if_bnf_ssn_nt_prv_cd
      ,p_susp_if_bnf_dob_nt_prv_cd      =>  p_susp_if_bnf_dob_nt_prv_cd
      ,p_susp_if_bnf_adr_nt_prv_cd      =>  p_susp_if_bnf_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_bnf_flag      =>  p_susp_if_ctfn_not_bnf_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_bnf_ctfn_determine_cd          =>  p_bnf_ctfn_determine_cd
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_alws_tmpry_id_crd_flag         =>  p_alws_tmpry_id_crd_flag
      ,p_nip_dflt_flag                  =>  p_nip_dflt_flag
      ,p_frfs_distr_mthd_cd             =>  p_frfs_distr_mthd_cd
      ,p_frfs_distr_mthd_rl             =>  p_frfs_distr_mthd_rl
      ,p_frfs_cntr_det_cd               =>  p_frfs_cntr_det_cd
      ,p_frfs_distr_det_cd              =>  p_frfs_distr_det_cd
      ,p_cost_alloc_keyflex_1_id        =>  p_cost_alloc_keyflex_1_id
      ,p_cost_alloc_keyflex_2_id        =>  p_cost_alloc_keyflex_2_id
      ,p_post_to_gl_flag                =>  p_post_to_gl_flag
      ,p_frfs_val_det_cd                =>  p_frfs_val_det_cd
      ,p_frfs_mx_cryfwd_val             =>  p_frfs_mx_cryfwd_val
      ,p_frfs_portion_det_cd            =>  p_frfs_portion_det_cd
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup            =>  p_legislation_subgroup
      ,p_group_pl_id                    =>  p_group_pl_id
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_function_code                  =>  p_function_code
      ,p_pl_yr_not_applcbl_flag        =>  p_pl_yr_not_applcbl_flag
      ,p_use_csd_rsd_prccng_cd         =>  p_use_csd_rsd_prccng_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Plan'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Plan
    --
  end;
  --
  ben_pln_ins.ins
    (
     p_pl_id                         => l_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_alws_qdro_flag                => p_alws_qdro_flag
    ,p_alws_qmcso_flag               => p_alws_qmcso_flag
    ,p_alws_reimbmts_flag            => p_alws_reimbmts_flag
    ,p_bnf_addl_instn_txt_alwd_flag  => p_bnf_addl_instn_txt_alwd_flag
    ,p_bnf_adrs_rqd_flag             => p_bnf_adrs_rqd_flag
    ,p_bnf_cntngt_bnfs_alwd_flag     => p_bnf_cntngt_bnfs_alwd_flag
    ,p_bnf_ctfn_rqd_flag             => p_bnf_ctfn_rqd_flag
    ,p_bnf_dob_rqd_flag              => p_bnf_dob_rqd_flag
    ,p_bnf_dsge_mnr_ttee_rqd_flag    => p_bnf_dsge_mnr_ttee_rqd_flag
    ,p_bnf_incrmt_amt                => p_bnf_incrmt_amt
    ,p_bnf_dflt_bnf_cd               => p_bnf_dflt_bnf_cd
    ,p_bnf_legv_id_rqd_flag          => p_bnf_legv_id_rqd_flag
    ,p_bnf_may_dsgt_org_flag         => p_bnf_may_dsgt_org_flag
    ,p_bnf_mn_dsgntbl_amt            => p_bnf_mn_dsgntbl_amt
    ,p_bnf_mn_dsgntbl_pct_val        => p_bnf_mn_dsgntbl_pct_val
    ,p_rqd_perd_enrt_nenrt_val       => p_rqd_perd_enrt_nenrt_val
    ,p_ordr_num                      => p_ordr_num
    ,p_bnf_pct_incrmt_val            => p_bnf_pct_incrmt_val
    ,p_bnf_pct_amt_alwd_cd           => p_bnf_pct_amt_alwd_cd
    ,p_bnf_qdro_rl_apls_flag         => p_bnf_qdro_rl_apls_flag
    ,p_dflt_to_asn_pndg_ctfn_cd      => p_dflt_to_asn_pndg_ctfn_cd
    ,p_dflt_to_asn_pndg_ctfn_rl      => p_dflt_to_asn_pndg_ctfn_rl
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_dpnt_dsgn_cd                  => p_dpnt_dsgn_cd
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_invk_dcln_prtn_pl_flag        => p_invk_dcln_prtn_pl_flag
    ,p_invk_flx_cr_pl_flag           => p_invk_flx_cr_pl_flag
    ,p_imptd_incm_calc_cd            => p_imptd_incm_calc_cd
    ,p_drvbl_dpnt_elig_flag          => p_drvbl_dpnt_elig_flag
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_pl_cd                         => p_pl_cd
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_ivr_ident                     => p_ivr_ident
    ,p_url_ref_name                  => p_url_ref_name
    ,p_cmpr_clms_to_cvg_or_bal_cd    => p_cmpr_clms_to_cvg_or_bal_cd
    ,p_cobra_pymt_due_dy_num         => p_cobra_pymt_due_dy_num
    ,p_dpnt_cvd_by_othr_apls_flag    => p_dpnt_cvd_by_othr_apls_flag
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_enrt_cd                       => p_enrt_cd
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_frfs_aply_flag                => p_frfs_aply_flag
    ,p_hc_pl_subj_hcfa_aprvl_flag    => p_hc_pl_subj_hcfa_aprvl_flag
    ,p_hghly_cmpd_rl_apls_flag       => p_hghly_cmpd_rl_apls_flag
    ,p_incptn_dt                     => p_incptn_dt
    ,p_mn_cvg_rl                     => p_mn_cvg_rl
    ,p_mn_cvg_rqd_amt                => p_mn_cvg_rqd_amt
    ,p_mn_opts_rqd_num               => p_mn_opts_rqd_num
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mx_cvg_rl                     => p_mx_cvg_rl
    ,p_mx_opts_alwd_num              => p_mx_opts_alwd_num
    ,p_mx_cvg_wcfn_mlt_num           => p_mx_cvg_wcfn_mlt_num
    ,p_mx_cvg_wcfn_amt               => p_mx_cvg_wcfn_amt
    ,p_mx_cvg_incr_alwd_amt          => p_mx_cvg_incr_alwd_amt
    ,p_mx_cvg_incr_wcf_alwd_amt      => p_mx_cvg_incr_wcf_alwd_amt
    ,p_mx_cvg_mlt_incr_num           => p_mx_cvg_mlt_incr_num
    ,p_mx_cvg_mlt_incr_wcf_num       => p_mx_cvg_mlt_incr_wcf_num
    ,p_mx_wtg_dt_to_use_cd           => p_mx_wtg_dt_to_use_cd
    ,p_mx_wtg_dt_to_use_rl           => p_mx_wtg_dt_to_use_rl
    ,p_mx_wtg_perd_prte_uom          => p_mx_wtg_perd_prte_uom
    ,p_mx_wtg_perd_prte_val          => p_mx_wtg_perd_prte_val
    ,p_mx_wtg_perd_rl                => p_mx_wtg_perd_rl
    ,p_nip_dflt_enrt_cd              => p_nip_dflt_enrt_cd
    ,p_nip_dflt_enrt_det_rl          => p_nip_dflt_enrt_det_rl
    ,p_dpnt_adrs_rqd_flag            => p_dpnt_adrs_rqd_flag
    ,p_dpnt_cvg_end_dt_cd            => p_dpnt_cvg_end_dt_cd
    ,p_dpnt_cvg_end_dt_rl            => p_dpnt_cvg_end_dt_rl
    ,p_dpnt_cvg_strt_dt_cd           => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl           => p_dpnt_cvg_strt_dt_rl
    ,p_dpnt_dob_rqd_flag             => p_dpnt_dob_rqd_flag
    ,p_dpnt_leg_id_rqd_flag          => p_dpnt_leg_id_rqd_flag
    ,p_dpnt_no_ctfn_rqd_flag         => p_dpnt_no_ctfn_rqd_flag
    ,p_no_mn_cvg_amt_apls_flag       => p_no_mn_cvg_amt_apls_flag
    ,p_no_mn_cvg_incr_apls_flag      => p_no_mn_cvg_incr_apls_flag
    ,p_no_mn_opts_num_apls_flag      => p_no_mn_opts_num_apls_flag
    ,p_no_mx_cvg_amt_apls_flag       => p_no_mx_cvg_amt_apls_flag
    ,p_no_mx_cvg_incr_apls_flag      => p_no_mx_cvg_incr_apls_flag
    ,p_no_mx_opts_num_apls_flag      => p_no_mx_opts_num_apls_flag
    ,p_nip_pl_uom                    => p_nip_pl_uom
    ,p_rqd_perd_enrt_nenrt_uom       => p_rqd_perd_enrt_nenrt_uom
    ,p_nip_acty_ref_perd_cd          => p_nip_acty_ref_perd_cd
    ,p_nip_enrt_info_rt_freq_cd      => p_nip_enrt_info_rt_freq_cd
    ,p_per_cvrd_cd                   => p_per_cvrd_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_postelcn_edit_rl              => p_postelcn_edit_rl
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_prort_prtl_yr_cvg_rstrn_cd    => p_prort_prtl_yr_cvg_rstrn_cd
    ,p_prort_prtl_yr_cvg_rstrn_rl    => p_prort_prtl_yr_cvg_rstrn_rl
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_svgs_pl_flag                  => p_svgs_pl_flag
    ,p_subj_to_imptd_incm_typ_cd     => p_subj_to_imptd_incm_typ_cd
    ,p_use_all_asnts_elig_flag       => p_use_all_asnts_elig_flag
    ,p_use_all_asnts_for_rt_flag     => p_use_all_asnts_for_rt_flag
    ,p_vstg_apls_flag                => p_vstg_apls_flag
    ,p_wvbl_flag                     => p_wvbl_flag
    ,p_hc_svc_typ_cd                 => p_hc_svc_typ_cd
    ,p_pl_stat_cd                    => p_pl_stat_cd
    ,p_prmry_fndg_mthd_cd            => p_prmry_fndg_mthd_cd
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_bnf_dsgn_cd                   => p_bnf_dsgn_cd
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_enrt_pl_opt_flag              => p_enrt_pl_opt_flag
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_may_enrl_pl_n_oipl_flag       => p_may_enrl_pl_n_oipl_flag
    ,p_enrt_rl                       => p_enrt_rl
    ,p_rqd_perd_enrt_nenrt_rl        => p_rqd_perd_enrt_nenrt_rl
    ,p_alws_unrstrctd_enrt_flag      => p_alws_unrstrctd_enrt_flag
    ,p_bnft_or_option_rstrctn_cd     => p_bnft_or_option_rstrctn_cd
    ,p_cvg_incr_r_decr_only_cd       => p_cvg_incr_r_decr_only_cd
    ,p_unsspnd_enrt_cd               => p_unsspnd_enrt_cd
    ,p_pln_attribute_category        => p_pln_attribute_category
    ,p_pln_attribute1                => p_pln_attribute1
    ,p_pln_attribute2                => p_pln_attribute2
    ,p_pln_attribute3                => p_pln_attribute3
    ,p_pln_attribute4                => p_pln_attribute4
    ,p_pln_attribute5                => p_pln_attribute5
    ,p_pln_attribute6                => p_pln_attribute6
    ,p_pln_attribute7                => p_pln_attribute7
    ,p_pln_attribute8                => p_pln_attribute8
    ,p_pln_attribute9                => p_pln_attribute9
    ,p_pln_attribute10               => p_pln_attribute10
    ,p_pln_attribute11               => p_pln_attribute11
    ,p_pln_attribute12               => p_pln_attribute12
    ,p_pln_attribute13               => p_pln_attribute13
    ,p_pln_attribute14               => p_pln_attribute14
    ,p_pln_attribute15               => p_pln_attribute15
    ,p_pln_attribute16               => p_pln_attribute16
    ,p_pln_attribute17               => p_pln_attribute17
    ,p_pln_attribute18               => p_pln_attribute18
    ,p_pln_attribute19               => p_pln_attribute19
    ,p_pln_attribute20               => p_pln_attribute20
    ,p_pln_attribute21               => p_pln_attribute21
    ,p_pln_attribute22               => p_pln_attribute22
    ,p_pln_attribute23               => p_pln_attribute23
    ,p_pln_attribute24               => p_pln_attribute24
    ,p_pln_attribute25               => p_pln_attribute25
    ,p_pln_attribute26               => p_pln_attribute26
    ,p_pln_attribute27               => p_pln_attribute27
    ,p_pln_attribute28               => p_pln_attribute28
    ,p_pln_attribute29               => p_pln_attribute29
    ,p_pln_attribute30               => p_pln_attribute30
    ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
    ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
    ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
    ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
    ,p_susp_if_bnf_ssn_nt_prv_cd      =>  p_susp_if_bnf_ssn_nt_prv_cd
    ,p_susp_if_bnf_dob_nt_prv_cd      =>  p_susp_if_bnf_dob_nt_prv_cd
    ,p_susp_if_bnf_adr_nt_prv_cd      =>  p_susp_if_bnf_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_bnf_flag      =>  p_susp_if_ctfn_not_bnf_flag
    ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
    ,p_bnf_ctfn_determine_cd          =>  p_bnf_ctfn_determine_cd
    ,p_object_version_number         => l_object_version_number
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_effective_date                => trunc(p_effective_date)
    ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
    ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
    ,p_alws_tmpry_id_crd_flag        => p_alws_tmpry_id_crd_flag
    ,p_nip_dflt_flag                 => p_nip_dflt_flag
    ,p_frfs_distr_mthd_cd            =>  p_frfs_distr_mthd_cd
    ,p_frfs_distr_mthd_rl            =>  p_frfs_distr_mthd_rl
    ,p_frfs_cntr_det_cd              =>  p_frfs_cntr_det_cd
    ,p_frfs_distr_det_cd             =>  p_frfs_distr_det_cd
    ,p_cost_alloc_keyflex_1_id       =>  p_cost_alloc_keyflex_1_id
    ,p_cost_alloc_keyflex_2_id       =>  p_cost_alloc_keyflex_2_id
    ,p_post_to_gl_flag               =>  p_post_to_gl_flag
    ,p_frfs_val_det_cd               =>  p_frfs_val_det_cd
    ,p_frfs_mx_cryfwd_val            =>  p_frfs_mx_cryfwd_val
    ,p_frfs_portion_det_cd           =>  p_frfs_portion_det_cd
    ,p_bndry_perd_cd                 =>  p_bndry_perd_cd
    ,p_short_name                     =>  p_short_name
    ,p_short_code                     =>  p_short_code
    ,p_legislation_code               =>  p_legislation_code
    ,p_legislation_subgroup           =>  p_legislation_subgroup
    ,p_group_pl_id                    =>  p_group_pl_id
    ,p_mapping_table_name             =>  p_mapping_table_name
    ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
    ,p_function_code                  =>  p_function_code
    ,p_pl_yr_not_applcbl_flag         =>  p_pl_yr_not_applcbl_flag
    ,p_use_csd_rsd_prccng_cd         =>  p_use_csd_rsd_prccng_cd
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Plan
    --
    ben_Plan_bk1.create_Plan_a
      (
       p_pl_id                          =>  l_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_alws_qdro_flag                 =>  p_alws_qdro_flag
      ,p_alws_qmcso_flag                =>  p_alws_qmcso_flag
      ,p_alws_reimbmts_flag             =>  p_alws_reimbmts_flag
      ,p_bnf_addl_instn_txt_alwd_flag   =>  p_bnf_addl_instn_txt_alwd_flag
      ,p_bnf_adrs_rqd_flag              =>  p_bnf_adrs_rqd_flag
      ,p_bnf_cntngt_bnfs_alwd_flag      =>  p_bnf_cntngt_bnfs_alwd_flag
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_bnf_dob_rqd_flag               =>  p_bnf_dob_rqd_flag
      ,p_bnf_dsge_mnr_ttee_rqd_flag     =>  p_bnf_dsge_mnr_ttee_rqd_flag
      ,p_bnf_incrmt_amt                 =>  p_bnf_incrmt_amt
      ,p_bnf_dflt_bnf_cd                =>  p_bnf_dflt_bnf_cd
      ,p_bnf_legv_id_rqd_flag           =>  p_bnf_legv_id_rqd_flag
      ,p_bnf_may_dsgt_org_flag          =>  p_bnf_may_dsgt_org_flag
      ,p_bnf_mn_dsgntbl_amt             =>  p_bnf_mn_dsgntbl_amt
      ,p_bnf_mn_dsgntbl_pct_val         =>  p_bnf_mn_dsgntbl_pct_val
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_bnf_pct_incrmt_val             =>  p_bnf_pct_incrmt_val
      ,p_bnf_pct_amt_alwd_cd            =>  p_bnf_pct_amt_alwd_cd
      ,p_bnf_qdro_rl_apls_flag          =>  p_bnf_qdro_rl_apls_flag
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_invk_dcln_prtn_pl_flag         =>  p_invk_dcln_prtn_pl_flag
      ,p_invk_flx_cr_pl_flag            =>  p_invk_flx_cr_pl_flag
      ,p_imptd_incm_calc_cd             =>  p_imptd_incm_calc_cd
      ,p_drvbl_dpnt_elig_flag           =>  p_drvbl_dpnt_elig_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_pl_cd                          =>  p_pl_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_cmpr_clms_to_cvg_or_bal_cd     =>  p_cmpr_clms_to_cvg_or_bal_cd
      ,p_cobra_pymt_due_dy_num          =>  p_cobra_pymt_due_dy_num
      ,p_dpnt_cvd_by_othr_apls_flag     =>  p_dpnt_cvd_by_othr_apls_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_frfs_aply_flag                 =>  p_frfs_aply_flag
      ,p_hc_pl_subj_hcfa_aprvl_flag     =>  p_hc_pl_subj_hcfa_aprvl_flag
      ,p_hghly_cmpd_rl_apls_flag        =>  p_hghly_cmpd_rl_apls_flag
      ,p_incptn_dt                      =>  p_incptn_dt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mn_cvg_rqd_amt                 =>  p_mn_cvg_rqd_amt
      ,p_mn_opts_rqd_num                =>  p_mn_opts_rqd_num
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_opts_alwd_num               =>  p_mx_opts_alwd_num
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_wtg_dt_to_use_cd            =>  p_mx_wtg_dt_to_use_cd
      ,p_mx_wtg_dt_to_use_rl            =>  p_mx_wtg_dt_to_use_rl
      ,p_mx_wtg_perd_prte_uom           =>  p_mx_wtg_perd_prte_uom
      ,p_mx_wtg_perd_prte_val           =>  p_mx_wtg_perd_prte_val
      ,p_mx_wtg_perd_rl                 =>  p_mx_wtg_perd_rl
      ,p_nip_dflt_enrt_cd               =>  p_nip_dflt_enrt_cd
      ,p_nip_dflt_enrt_det_rl           =>  p_nip_dflt_enrt_det_rl
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_dpnt_leg_id_rqd_flag           =>  p_dpnt_leg_id_rqd_flag
      ,p_dpnt_no_ctfn_rqd_flag          =>  p_dpnt_no_ctfn_rqd_flag
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mn_opts_num_apls_flag       =>  p_no_mn_opts_num_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_no_mx_opts_num_apls_flag       =>  p_no_mx_opts_num_apls_flag
      ,p_nip_pl_uom                     =>  p_nip_pl_uom
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_nip_acty_ref_perd_cd           =>  p_nip_acty_ref_perd_cd
      ,p_nip_enrt_info_rt_freq_cd       =>  p_nip_enrt_info_rt_freq_cd
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_svgs_pl_flag                   =>  p_svgs_pl_flag
      ,p_subj_to_imptd_incm_typ_cd      =>  p_subj_to_imptd_incm_typ_cd
      ,p_use_all_asnts_elig_flag        =>  p_use_all_asnts_elig_flag
      ,p_use_all_asnts_for_rt_flag      =>  p_use_all_asnts_for_rt_flag
      ,p_vstg_apls_flag                 =>  p_vstg_apls_flag
      ,p_wvbl_flag                      =>  p_wvbl_flag
      ,p_hc_svc_typ_cd                  =>  p_hc_svc_typ_cd
      ,p_pl_stat_cd                     =>  p_pl_stat_cd
      ,p_prmry_fndg_mthd_cd             =>  p_prmry_fndg_mthd_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_bnf_dsgn_cd                    =>  p_bnf_dsgn_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_pl_opt_flag               =>  p_enrt_pl_opt_flag
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_may_enrl_pl_n_oipl_flag        =>  p_may_enrl_pl_n_oipl_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_pln_attribute_category         =>  p_pln_attribute_category
      ,p_pln_attribute1                 =>  p_pln_attribute1
      ,p_pln_attribute2                 =>  p_pln_attribute2
      ,p_pln_attribute3                 =>  p_pln_attribute3
      ,p_pln_attribute4                 =>  p_pln_attribute4
      ,p_pln_attribute5                 =>  p_pln_attribute5
      ,p_pln_attribute6                 =>  p_pln_attribute6
      ,p_pln_attribute7                 =>  p_pln_attribute7
      ,p_pln_attribute8                 =>  p_pln_attribute8
      ,p_pln_attribute9                 =>  p_pln_attribute9
      ,p_pln_attribute10                =>  p_pln_attribute10
      ,p_pln_attribute11                =>  p_pln_attribute11
      ,p_pln_attribute12                =>  p_pln_attribute12
      ,p_pln_attribute13                =>  p_pln_attribute13
      ,p_pln_attribute14                =>  p_pln_attribute14
      ,p_pln_attribute15                =>  p_pln_attribute15
      ,p_pln_attribute16                =>  p_pln_attribute16
      ,p_pln_attribute17                =>  p_pln_attribute17
      ,p_pln_attribute18                =>  p_pln_attribute18
      ,p_pln_attribute19                =>  p_pln_attribute19
      ,p_pln_attribute20                =>  p_pln_attribute20
      ,p_pln_attribute21                =>  p_pln_attribute21
      ,p_pln_attribute22                =>  p_pln_attribute22
      ,p_pln_attribute23                =>  p_pln_attribute23
      ,p_pln_attribute24                =>  p_pln_attribute24
      ,p_pln_attribute25                =>  p_pln_attribute25
      ,p_pln_attribute26                =>  p_pln_attribute26
      ,p_pln_attribute27                =>  p_pln_attribute27
      ,p_pln_attribute28                =>  p_pln_attribute28
      ,p_pln_attribute29                =>  p_pln_attribute29
      ,p_pln_attribute30                =>  p_pln_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_susp_if_bnf_ssn_nt_prv_cd      =>  p_susp_if_bnf_ssn_nt_prv_cd
      ,p_susp_if_bnf_dob_nt_prv_cd      =>  p_susp_if_bnf_dob_nt_prv_cd
      ,p_susp_if_bnf_adr_nt_prv_cd      =>  p_susp_if_bnf_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_bnf_flag      =>  p_susp_if_ctfn_not_bnf_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_bnf_ctfn_determine_cd          =>  p_bnf_ctfn_determine_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_alws_tmpry_id_crd_flag         =>  p_alws_tmpry_id_crd_flag
      ,p_nip_dflt_flag                  =>  p_nip_dflt_flag
      ,p_frfs_distr_mthd_cd             =>  p_frfs_distr_mthd_cd
      ,p_frfs_distr_mthd_rl             =>  p_frfs_distr_mthd_rl
      ,p_frfs_cntr_det_cd               =>  p_frfs_cntr_det_cd
      ,p_frfs_distr_det_cd              =>  p_frfs_distr_det_cd
      ,p_cost_alloc_keyflex_1_id        =>  p_cost_alloc_keyflex_1_id
      ,p_cost_alloc_keyflex_2_id        =>  p_cost_alloc_keyflex_2_id
      ,p_post_to_gl_flag                =>  p_post_to_gl_flag
      ,p_frfs_val_det_cd                =>  p_frfs_val_det_cd
      ,p_frfs_mx_cryfwd_val             =>  p_frfs_mx_cryfwd_val
      ,p_frfs_portion_det_cd            =>  p_frfs_portion_det_cd
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup            =>  p_legislation_subgroup
      ,p_group_pl_id                    =>  p_group_pl_id
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_function_code                  =>  p_function_code
      ,p_pl_yr_not_applcbl_flag         =>  p_pl_yr_not_applcbl_flag
      ,p_use_csd_rsd_prccng_cd          =>  p_use_csd_rsd_prccng_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Plan'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Plan
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
  p_pl_id := l_pl_id;
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
    ROLLBACK TO create_Plan;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Plan;
    /* Inserted for nocopy changes */
    p_pl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_Plan;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan
  (p_validate                       in  boolean   default false
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
  ,p_rqd_perd_enrt_nenrt_val        in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
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
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2  default hr_api.g_varchar2
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
  ,p_may_enrl_pl_n_oipl_flag        in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rl                        in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_rl         in  number    default hr_api.g_number
  ,p_alws_unrstrctd_enrt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_bnft_or_option_rstrctn_cd      in  varchar2  default hr_api.g_varchar2
  ,p_cvg_incr_r_decr_only_cd        in  varchar2  default hr_api.g_varchar2
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
  ,p_short_code                     in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup           in  varchar2  default hr_api.g_varchar2
  ,p_group_pl_id                    in  number    default hr_api.g_number
  ,p_mapping_table_name             in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_pk_id            in  number    default hr_api.g_number
  ,p_function_code                  in  varchar2  default hr_api.g_varchar2
  ,p_pl_yr_not_applcbl_flag         in  varchar2  default hr_api.g_varchar2
  ,p_use_csd_rsd_prccng_cd          in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan';
  l_object_version_number ben_pl_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Plan;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Plan
    --
    ben_Plan_bk2.update_Plan_b
      (p_pl_id                          =>  p_pl_id
      ,p_name                           =>  p_name
      ,p_alws_qdro_flag                 =>  p_alws_qdro_flag
      ,p_alws_qmcso_flag                =>  p_alws_qmcso_flag
      ,p_alws_reimbmts_flag             =>  p_alws_reimbmts_flag
      ,p_bnf_addl_instn_txt_alwd_flag   =>  p_bnf_addl_instn_txt_alwd_flag
      ,p_bnf_adrs_rqd_flag              =>  p_bnf_adrs_rqd_flag
      ,p_bnf_cntngt_bnfs_alwd_flag      =>  p_bnf_cntngt_bnfs_alwd_flag
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_bnf_dob_rqd_flag               =>  p_bnf_dob_rqd_flag
      ,p_bnf_dsge_mnr_ttee_rqd_flag     =>  p_bnf_dsge_mnr_ttee_rqd_flag
      ,p_bnf_incrmt_amt                 =>  p_bnf_incrmt_amt
      ,p_bnf_dflt_bnf_cd                =>  p_bnf_dflt_bnf_cd
      ,p_bnf_legv_id_rqd_flag           =>  p_bnf_legv_id_rqd_flag
      ,p_bnf_may_dsgt_org_flag          =>  p_bnf_may_dsgt_org_flag
      ,p_bnf_mn_dsgntbl_amt             =>  p_bnf_mn_dsgntbl_amt
      ,p_bnf_mn_dsgntbl_pct_val         =>  p_bnf_mn_dsgntbl_pct_val
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_bnf_pct_incrmt_val             =>  p_bnf_pct_incrmt_val
      ,p_bnf_pct_amt_alwd_cd            =>  p_bnf_pct_amt_alwd_cd
      ,p_bnf_qdro_rl_apls_flag          =>  p_bnf_qdro_rl_apls_flag
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_invk_dcln_prtn_pl_flag         =>  p_invk_dcln_prtn_pl_flag
      ,p_invk_flx_cr_pl_flag            =>  p_invk_flx_cr_pl_flag
      ,p_imptd_incm_calc_cd             =>  p_imptd_incm_calc_cd
      ,p_drvbl_dpnt_elig_flag           =>  p_drvbl_dpnt_elig_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_pl_cd                          =>  p_pl_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_cmpr_clms_to_cvg_or_bal_cd     =>  p_cmpr_clms_to_cvg_or_bal_cd
      ,p_cobra_pymt_due_dy_num          =>  p_cobra_pymt_due_dy_num
      ,p_dpnt_cvd_by_othr_apls_flag     =>  p_dpnt_cvd_by_othr_apls_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_frfs_aply_flag                 =>  p_frfs_aply_flag
      ,p_hc_pl_subj_hcfa_aprvl_flag     =>  p_hc_pl_subj_hcfa_aprvl_flag
      ,p_hghly_cmpd_rl_apls_flag        =>  p_hghly_cmpd_rl_apls_flag
      ,p_incptn_dt                      =>  p_incptn_dt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mn_cvg_rqd_amt                 =>  p_mn_cvg_rqd_amt
      ,p_mn_opts_rqd_num                =>  p_mn_opts_rqd_num
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_opts_alwd_num               =>  p_mx_opts_alwd_num
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_wtg_dt_to_use_cd            =>  p_mx_wtg_dt_to_use_cd
      ,p_mx_wtg_dt_to_use_rl            =>  p_mx_wtg_dt_to_use_rl
      ,p_mx_wtg_perd_prte_uom           =>  p_mx_wtg_perd_prte_uom
      ,p_mx_wtg_perd_prte_val           =>  p_mx_wtg_perd_prte_val
      ,p_mx_wtg_perd_rl                 =>  p_mx_wtg_perd_rl
      ,p_nip_dflt_enrt_cd               =>  p_nip_dflt_enrt_cd
      ,p_nip_dflt_enrt_det_rl           =>  p_nip_dflt_enrt_det_rl
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_dpnt_leg_id_rqd_flag           =>  p_dpnt_leg_id_rqd_flag
      ,p_dpnt_no_ctfn_rqd_flag          =>  p_dpnt_no_ctfn_rqd_flag
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mn_opts_num_apls_flag       =>  p_no_mn_opts_num_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_no_mx_opts_num_apls_flag       =>  p_no_mx_opts_num_apls_flag
      ,p_nip_pl_uom                     =>  p_nip_pl_uom
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_nip_acty_ref_perd_cd           =>  p_nip_acty_ref_perd_cd
      ,p_nip_enrt_info_rt_freq_cd       =>  p_nip_enrt_info_rt_freq_cd
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_svgs_pl_flag                   =>  p_svgs_pl_flag
      ,p_subj_to_imptd_incm_typ_cd      =>  p_subj_to_imptd_incm_typ_cd
      ,p_use_all_asnts_elig_flag        =>  p_use_all_asnts_elig_flag
      ,p_use_all_asnts_for_rt_flag      =>  p_use_all_asnts_for_rt_flag
      ,p_vstg_apls_flag                 =>  p_vstg_apls_flag
      ,p_wvbl_flag                      =>  p_wvbl_flag
      ,p_hc_svc_typ_cd                  =>  p_hc_svc_typ_cd
      ,p_pl_stat_cd                     =>  p_pl_stat_cd
      ,p_prmry_fndg_mthd_cd             =>  p_prmry_fndg_mthd_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_bnf_dsgn_cd                    =>  p_bnf_dsgn_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_pl_opt_flag               =>  p_enrt_pl_opt_flag
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_may_enrl_pl_n_oipl_flag        =>  p_may_enrl_pl_n_oipl_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_pln_attribute_category         =>  p_pln_attribute_category
      ,p_pln_attribute1                 =>  p_pln_attribute1
      ,p_pln_attribute2                 =>  p_pln_attribute2
      ,p_pln_attribute3                 =>  p_pln_attribute3
      ,p_pln_attribute4                 =>  p_pln_attribute4
      ,p_pln_attribute5                 =>  p_pln_attribute5
      ,p_pln_attribute6                 =>  p_pln_attribute6
      ,p_pln_attribute7                 =>  p_pln_attribute7
      ,p_pln_attribute8                 =>  p_pln_attribute8
      ,p_pln_attribute9                 =>  p_pln_attribute9
      ,p_pln_attribute10                =>  p_pln_attribute10
      ,p_pln_attribute11                =>  p_pln_attribute11
      ,p_pln_attribute12                =>  p_pln_attribute12
      ,p_pln_attribute13                =>  p_pln_attribute13
      ,p_pln_attribute14                =>  p_pln_attribute14
      ,p_pln_attribute15                =>  p_pln_attribute15
      ,p_pln_attribute16                =>  p_pln_attribute16
      ,p_pln_attribute17                =>  p_pln_attribute17
      ,p_pln_attribute18                =>  p_pln_attribute18
      ,p_pln_attribute19                =>  p_pln_attribute19
      ,p_pln_attribute20                =>  p_pln_attribute20
      ,p_pln_attribute21                =>  p_pln_attribute21
      ,p_pln_attribute22                =>  p_pln_attribute22
      ,p_pln_attribute23                =>  p_pln_attribute23
      ,p_pln_attribute24                =>  p_pln_attribute24
      ,p_pln_attribute25                =>  p_pln_attribute25
      ,p_pln_attribute26                =>  p_pln_attribute26
      ,p_pln_attribute27                =>  p_pln_attribute27
      ,p_pln_attribute28                =>  p_pln_attribute28
      ,p_pln_attribute29                =>  p_pln_attribute29
      ,p_pln_attribute30                =>  p_pln_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_susp_if_bnf_ssn_nt_prv_cd      =>  p_susp_if_bnf_ssn_nt_prv_cd
      ,p_susp_if_bnf_dob_nt_prv_cd      =>  p_susp_if_bnf_dob_nt_prv_cd
      ,p_susp_if_bnf_adr_nt_prv_cd      =>  p_susp_if_bnf_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_bnf_flag      =>  p_susp_if_ctfn_not_bnf_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_bnf_ctfn_determine_cd          =>  p_bnf_ctfn_determine_cd
      ,p_object_version_number          =>  p_object_version_number
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_alws_tmpry_id_crd_flag         =>  p_alws_tmpry_id_crd_flag
      ,p_nip_dflt_flag                  =>  p_nip_dflt_flag
      ,p_frfs_distr_mthd_cd             =>  p_frfs_distr_mthd_cd
      ,p_frfs_distr_mthd_rl             =>  p_frfs_distr_mthd_rl
      ,p_frfs_cntr_det_cd               =>  p_frfs_cntr_det_cd
      ,p_frfs_distr_det_cd              =>  p_frfs_distr_det_cd
      ,p_cost_alloc_keyflex_1_id        =>  p_cost_alloc_keyflex_1_id
      ,p_cost_alloc_keyflex_2_id        =>  p_cost_alloc_keyflex_2_id
      ,p_post_to_gl_flag                =>  p_post_to_gl_flag
      ,p_frfs_val_det_cd                =>  p_frfs_val_det_cd
      ,p_frfs_mx_cryfwd_val             =>  p_frfs_mx_cryfwd_val
      ,p_frfs_portion_det_cd            =>  p_frfs_portion_det_cd
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup           =>  p_legislation_subgroup
      ,p_group_pl_id                    =>  p_group_pl_id
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_function_code                  =>  p_function_code
      ,p_pl_yr_not_applcbl_flag         =>  p_pl_yr_not_applcbl_flag
      ,p_use_csd_rsd_prccng_cd          =>  p_use_csd_rsd_prccng_cd

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Plan
    --
  end;
  --
   ben_pln_upd.upd
    (
     p_pl_id                         => p_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_alws_qdro_flag                => p_alws_qdro_flag
    ,p_alws_qmcso_flag               => p_alws_qmcso_flag
    ,p_alws_reimbmts_flag            => p_alws_reimbmts_flag
    ,p_bnf_addl_instn_txt_alwd_flag  => p_bnf_addl_instn_txt_alwd_flag
    ,p_bnf_adrs_rqd_flag             => p_bnf_adrs_rqd_flag
    ,p_bnf_cntngt_bnfs_alwd_flag     => p_bnf_cntngt_bnfs_alwd_flag
    ,p_bnf_ctfn_rqd_flag             => p_bnf_ctfn_rqd_flag
    ,p_bnf_dob_rqd_flag              => p_bnf_dob_rqd_flag
    ,p_bnf_dsge_mnr_ttee_rqd_flag    => p_bnf_dsge_mnr_ttee_rqd_flag
    ,p_bnf_incrmt_amt                => p_bnf_incrmt_amt
    ,p_bnf_dflt_bnf_cd               => p_bnf_dflt_bnf_cd
    ,p_bnf_legv_id_rqd_flag          => p_bnf_legv_id_rqd_flag
    ,p_bnf_may_dsgt_org_flag         => p_bnf_may_dsgt_org_flag
    ,p_bnf_mn_dsgntbl_amt            => p_bnf_mn_dsgntbl_amt
    ,p_bnf_mn_dsgntbl_pct_val        => p_bnf_mn_dsgntbl_pct_val
    ,p_rqd_perd_enrt_nenrt_val       => p_rqd_perd_enrt_nenrt_val
    ,p_ordr_num                      => p_ordr_num
    ,p_bnf_pct_incrmt_val            => p_bnf_pct_incrmt_val
    ,p_bnf_pct_amt_alwd_cd           => p_bnf_pct_amt_alwd_cd
    ,p_bnf_qdro_rl_apls_flag         => p_bnf_qdro_rl_apls_flag
    ,p_dflt_to_asn_pndg_ctfn_cd      => p_dflt_to_asn_pndg_ctfn_cd
    ,p_dflt_to_asn_pndg_ctfn_rl      => p_dflt_to_asn_pndg_ctfn_rl
    ,p_drvbl_fctr_apls_rts_flag      => p_drvbl_fctr_apls_rts_flag
    ,p_drvbl_fctr_prtn_elig_flag     => p_drvbl_fctr_prtn_elig_flag
    ,p_dpnt_dsgn_cd                  => p_dpnt_dsgn_cd
    ,p_elig_apls_flag                => p_elig_apls_flag
    ,p_invk_dcln_prtn_pl_flag        => p_invk_dcln_prtn_pl_flag
    ,p_invk_flx_cr_pl_flag           => p_invk_flx_cr_pl_flag
    ,p_imptd_incm_calc_cd            => p_imptd_incm_calc_cd
    ,p_drvbl_dpnt_elig_flag          => p_drvbl_dpnt_elig_flag
    ,p_trk_inelig_per_flag           => p_trk_inelig_per_flag
    ,p_pl_cd                         => p_pl_cd
    ,p_auto_enrt_mthd_rl             => p_auto_enrt_mthd_rl
    ,p_ivr_ident                     => p_ivr_ident
    ,p_url_ref_name                  => p_url_ref_name
    ,p_cmpr_clms_to_cvg_or_bal_cd    => p_cmpr_clms_to_cvg_or_bal_cd
    ,p_cobra_pymt_due_dy_num         => p_cobra_pymt_due_dy_num
    ,p_dpnt_cvd_by_othr_apls_flag    => p_dpnt_cvd_by_othr_apls_flag
    ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
    ,p_enrt_cd                       => p_enrt_cd
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_frfs_aply_flag                => p_frfs_aply_flag
    ,p_hc_pl_subj_hcfa_aprvl_flag    => p_hc_pl_subj_hcfa_aprvl_flag
    ,p_hghly_cmpd_rl_apls_flag       => p_hghly_cmpd_rl_apls_flag
    ,p_incptn_dt                     => p_incptn_dt
    ,p_mn_cvg_rl                     => p_mn_cvg_rl
    ,p_mn_cvg_rqd_amt                => p_mn_cvg_rqd_amt
    ,p_mn_opts_rqd_num               => p_mn_opts_rqd_num
    ,p_mx_cvg_alwd_amt               => p_mx_cvg_alwd_amt
    ,p_mx_cvg_rl                     => p_mx_cvg_rl
    ,p_mx_opts_alwd_num              => p_mx_opts_alwd_num
    ,p_mx_cvg_wcfn_mlt_num           => p_mx_cvg_wcfn_mlt_num
    ,p_mx_cvg_wcfn_amt               => p_mx_cvg_wcfn_amt
    ,p_mx_cvg_incr_alwd_amt          => p_mx_cvg_incr_alwd_amt
    ,p_mx_cvg_incr_wcf_alwd_amt      => p_mx_cvg_incr_wcf_alwd_amt
    ,p_mx_cvg_mlt_incr_num           => p_mx_cvg_mlt_incr_num
    ,p_mx_cvg_mlt_incr_wcf_num       => p_mx_cvg_mlt_incr_wcf_num
    ,p_mx_wtg_dt_to_use_cd           => p_mx_wtg_dt_to_use_cd
    ,p_mx_wtg_dt_to_use_rl           => p_mx_wtg_dt_to_use_rl
    ,p_mx_wtg_perd_prte_uom          => p_mx_wtg_perd_prte_uom
    ,p_mx_wtg_perd_prte_val          => p_mx_wtg_perd_prte_val
    ,p_mx_wtg_perd_rl                => p_mx_wtg_perd_rl
    ,p_nip_dflt_enrt_cd              => p_nip_dflt_enrt_cd
    ,p_nip_dflt_enrt_det_rl          => p_nip_dflt_enrt_det_rl
    ,p_dpnt_adrs_rqd_flag            => p_dpnt_adrs_rqd_flag
    ,p_dpnt_cvg_end_dt_cd            => p_dpnt_cvg_end_dt_cd
    ,p_dpnt_cvg_end_dt_rl            => p_dpnt_cvg_end_dt_rl
    ,p_dpnt_cvg_strt_dt_cd           => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl           => p_dpnt_cvg_strt_dt_rl
    ,p_dpnt_dob_rqd_flag             => p_dpnt_dob_rqd_flag
    ,p_dpnt_leg_id_rqd_flag          => p_dpnt_leg_id_rqd_flag
    ,p_dpnt_no_ctfn_rqd_flag         => p_dpnt_no_ctfn_rqd_flag
    ,p_no_mn_cvg_amt_apls_flag       => p_no_mn_cvg_amt_apls_flag
    ,p_no_mn_cvg_incr_apls_flag      => p_no_mn_cvg_incr_apls_flag
    ,p_no_mn_opts_num_apls_flag      => p_no_mn_opts_num_apls_flag
    ,p_no_mx_cvg_amt_apls_flag       => p_no_mx_cvg_amt_apls_flag
    ,p_no_mx_cvg_incr_apls_flag      => p_no_mx_cvg_incr_apls_flag
    ,p_no_mx_opts_num_apls_flag      => p_no_mx_opts_num_apls_flag
    ,p_nip_pl_uom                    => p_nip_pl_uom
    ,p_rqd_perd_enrt_nenrt_uom       => p_rqd_perd_enrt_nenrt_uom
    ,p_nip_acty_ref_perd_cd          => p_nip_acty_ref_perd_cd
    ,p_nip_enrt_info_rt_freq_cd      => p_nip_enrt_info_rt_freq_cd
    ,p_per_cvrd_cd                   => p_per_cvrd_cd
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_postelcn_edit_rl              => p_postelcn_edit_rl
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_prort_prtl_yr_cvg_rstrn_cd    => p_prort_prtl_yr_cvg_rstrn_cd
    ,p_prort_prtl_yr_cvg_rstrn_rl    => p_prort_prtl_yr_cvg_rstrn_rl
    ,p_prtn_elig_ovrid_alwd_flag     => p_prtn_elig_ovrid_alwd_flag
    ,p_svgs_pl_flag                  => p_svgs_pl_flag
    ,p_subj_to_imptd_incm_typ_cd     => p_subj_to_imptd_incm_typ_cd
    ,p_use_all_asnts_elig_flag       => p_use_all_asnts_elig_flag
    ,p_use_all_asnts_for_rt_flag     => p_use_all_asnts_for_rt_flag
    ,p_vstg_apls_flag                => p_vstg_apls_flag
    ,p_wvbl_flag                     => p_wvbl_flag
    ,p_hc_svc_typ_cd                 => p_hc_svc_typ_cd
    ,p_pl_stat_cd                    => p_pl_stat_cd
    ,p_prmry_fndg_mthd_cd            => p_prmry_fndg_mthd_cd
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_bnf_dsgn_cd                   => p_bnf_dsgn_cd
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_enrt_pl_opt_flag              => p_enrt_pl_opt_flag
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_may_enrl_pl_n_oipl_flag       => p_may_enrl_pl_n_oipl_flag
    ,p_enrt_rl                       => p_enrt_rl
    ,p_rqd_perd_enrt_nenrt_rl        => p_rqd_perd_enrt_nenrt_rl
    ,p_alws_unrstrctd_enrt_flag      => p_alws_unrstrctd_enrt_flag
    ,p_bnft_or_option_rstrctn_cd     => p_bnft_or_option_rstrctn_cd
    ,p_cvg_incr_r_decr_only_cd       => p_cvg_incr_r_decr_only_cd
    ,p_unsspnd_enrt_cd               => p_unsspnd_enrt_cd
    ,p_pln_attribute_category        => p_pln_attribute_category
    ,p_pln_attribute1                => p_pln_attribute1
    ,p_pln_attribute2                => p_pln_attribute2
    ,p_pln_attribute3                => p_pln_attribute3
    ,p_pln_attribute4                => p_pln_attribute4
    ,p_pln_attribute5                => p_pln_attribute5
    ,p_pln_attribute6                => p_pln_attribute6
    ,p_pln_attribute7                => p_pln_attribute7
    ,p_pln_attribute8                => p_pln_attribute8
    ,p_pln_attribute9                => p_pln_attribute9
    ,p_pln_attribute10               => p_pln_attribute10
    ,p_pln_attribute11               => p_pln_attribute11
    ,p_pln_attribute12               => p_pln_attribute12
    ,p_pln_attribute13               => p_pln_attribute13
    ,p_pln_attribute14               => p_pln_attribute14
    ,p_pln_attribute15               => p_pln_attribute15
    ,p_pln_attribute16               => p_pln_attribute16
    ,p_pln_attribute17               => p_pln_attribute17
    ,p_pln_attribute18               => p_pln_attribute18
    ,p_pln_attribute19               => p_pln_attribute19
    ,p_pln_attribute20               => p_pln_attribute20
    ,p_pln_attribute21               => p_pln_attribute21
    ,p_pln_attribute22               => p_pln_attribute22
    ,p_pln_attribute23               => p_pln_attribute23
    ,p_pln_attribute24               => p_pln_attribute24
    ,p_pln_attribute25               => p_pln_attribute25
    ,p_pln_attribute26               => p_pln_attribute26
    ,p_pln_attribute27               => p_pln_attribute27
    ,p_pln_attribute28               => p_pln_attribute28
    ,p_pln_attribute29               => p_pln_attribute29
    ,p_pln_attribute30               => p_pln_attribute30
    ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
    ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
    ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
    ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
    ,p_susp_if_bnf_ssn_nt_prv_cd      =>  p_susp_if_bnf_ssn_nt_prv_cd
    ,p_susp_if_bnf_dob_nt_prv_cd      =>  p_susp_if_bnf_dob_nt_prv_cd
    ,p_susp_if_bnf_adr_nt_prv_cd      =>  p_susp_if_bnf_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_bnf_flag      =>  p_susp_if_ctfn_not_bnf_flag
    ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
    ,p_bnf_ctfn_determine_cd          =>  p_bnf_ctfn_determine_cd
    ,p_object_version_number         => l_object_version_number
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_vrfy_fmly_mmbr_cd             =>  p_vrfy_fmly_mmbr_cd
    ,p_vrfy_fmly_mmbr_rl             =>  p_vrfy_fmly_mmbr_rl
    ,p_alws_tmpry_id_crd_flag        => p_alws_tmpry_id_crd_flag
    ,p_nip_dflt_flag                 =>  p_nip_dflt_flag
    ,p_frfs_distr_mthd_cd            =>  p_frfs_distr_mthd_cd
    ,p_frfs_distr_mthd_rl            =>  p_frfs_distr_mthd_rl
    ,p_frfs_cntr_det_cd              =>  p_frfs_cntr_det_cd
    ,p_frfs_distr_det_cd             =>  p_frfs_distr_det_cd
    ,p_cost_alloc_keyflex_1_id       =>  p_cost_alloc_keyflex_1_id
    ,p_cost_alloc_keyflex_2_id       =>  p_cost_alloc_keyflex_2_id
    ,p_post_to_gl_flag               =>  p_post_to_gl_flag
    ,p_frfs_val_det_cd               =>  p_frfs_val_det_cd
    ,p_frfs_mx_cryfwd_val            =>  p_frfs_mx_cryfwd_val
    ,p_frfs_portion_det_cd           =>  p_frfs_portion_det_cd
    ,p_bndry_perd_cd                 =>  p_bndry_perd_cd
    ,p_short_name                    =>  p_short_name
    ,p_short_code                    =>  p_short_code
    ,p_legislation_code              =>  p_legislation_code
    ,p_legislation_subgroup          =>  p_legislation_subgroup
    ,p_group_pl_id                   =>  p_group_pl_id
    ,p_mapping_table_name            =>  p_mapping_table_name
    ,p_mapping_table_pk_id           =>  p_mapping_table_pk_id
    ,p_function_code                 =>  p_function_code
    ,p_pl_yr_not_applcbl_flag        =>  p_pl_yr_not_applcbl_flag
    ,p_use_csd_rsd_prccng_cd        =>  p_use_csd_rsd_prccng_cd
    );
  --
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Plan
    --
    ben_Plan_bk2.update_Plan_a
      (
       p_pl_id                          =>  p_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_alws_qdro_flag                 =>  p_alws_qdro_flag
      ,p_alws_qmcso_flag                =>  p_alws_qmcso_flag
      ,p_alws_reimbmts_flag             =>  p_alws_reimbmts_flag
      ,p_bnf_addl_instn_txt_alwd_flag   =>  p_bnf_addl_instn_txt_alwd_flag
      ,p_bnf_adrs_rqd_flag              =>  p_bnf_adrs_rqd_flag
      ,p_bnf_cntngt_bnfs_alwd_flag      =>  p_bnf_cntngt_bnfs_alwd_flag
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_bnf_dob_rqd_flag               =>  p_bnf_dob_rqd_flag
      ,p_bnf_dsge_mnr_ttee_rqd_flag     =>  p_bnf_dsge_mnr_ttee_rqd_flag
      ,p_bnf_incrmt_amt                 =>  p_bnf_incrmt_amt
      ,p_bnf_dflt_bnf_cd                =>  p_bnf_dflt_bnf_cd
      ,p_bnf_legv_id_rqd_flag           =>  p_bnf_legv_id_rqd_flag
      ,p_bnf_may_dsgt_org_flag          =>  p_bnf_may_dsgt_org_flag
      ,p_bnf_mn_dsgntbl_amt             =>  p_bnf_mn_dsgntbl_amt
      ,p_bnf_mn_dsgntbl_pct_val         =>  p_bnf_mn_dsgntbl_pct_val
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_ordr_num                       =>  p_ordr_num
      ,p_bnf_pct_incrmt_val             =>  p_bnf_pct_incrmt_val
      ,p_bnf_pct_amt_alwd_cd            =>  p_bnf_pct_amt_alwd_cd
      ,p_bnf_qdro_rl_apls_flag          =>  p_bnf_qdro_rl_apls_flag
      ,p_dflt_to_asn_pndg_ctfn_cd       =>  p_dflt_to_asn_pndg_ctfn_cd
      ,p_dflt_to_asn_pndg_ctfn_rl       =>  p_dflt_to_asn_pndg_ctfn_rl
      ,p_drvbl_fctr_apls_rts_flag       =>  p_drvbl_fctr_apls_rts_flag
      ,p_drvbl_fctr_prtn_elig_flag      =>  p_drvbl_fctr_prtn_elig_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_elig_apls_flag                 =>  p_elig_apls_flag
      ,p_invk_dcln_prtn_pl_flag         =>  p_invk_dcln_prtn_pl_flag
      ,p_invk_flx_cr_pl_flag            =>  p_invk_flx_cr_pl_flag
      ,p_imptd_incm_calc_cd             =>  p_imptd_incm_calc_cd
      ,p_drvbl_dpnt_elig_flag           =>  p_drvbl_dpnt_elig_flag
      ,p_trk_inelig_per_flag            =>  p_trk_inelig_per_flag
      ,p_pl_cd                          =>  p_pl_cd
      ,p_auto_enrt_mthd_rl              =>  p_auto_enrt_mthd_rl
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_url_ref_name                   =>  p_url_ref_name
      ,p_cmpr_clms_to_cvg_or_bal_cd     =>  p_cmpr_clms_to_cvg_or_bal_cd
      ,p_cobra_pymt_due_dy_num          =>  p_cobra_pymt_due_dy_num
      ,p_dpnt_cvd_by_othr_apls_flag     =>  p_dpnt_cvd_by_othr_apls_flag
      ,p_enrt_mthd_cd                   =>  p_enrt_mthd_cd
      ,p_enrt_cd                        =>  p_enrt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_frfs_aply_flag                 =>  p_frfs_aply_flag
      ,p_hc_pl_subj_hcfa_aprvl_flag     =>  p_hc_pl_subj_hcfa_aprvl_flag
      ,p_hghly_cmpd_rl_apls_flag        =>  p_hghly_cmpd_rl_apls_flag
      ,p_incptn_dt                      =>  p_incptn_dt
      ,p_mn_cvg_rl                      =>  p_mn_cvg_rl
      ,p_mn_cvg_rqd_amt                 =>  p_mn_cvg_rqd_amt
      ,p_mn_opts_rqd_num                =>  p_mn_opts_rqd_num
      ,p_mx_cvg_alwd_amt                =>  p_mx_cvg_alwd_amt
      ,p_mx_cvg_rl                      =>  p_mx_cvg_rl
      ,p_mx_opts_alwd_num               =>  p_mx_opts_alwd_num
      ,p_mx_cvg_wcfn_mlt_num            =>  p_mx_cvg_wcfn_mlt_num
      ,p_mx_cvg_wcfn_amt                =>  p_mx_cvg_wcfn_amt
      ,p_mx_cvg_incr_alwd_amt           =>  p_mx_cvg_incr_alwd_amt
      ,p_mx_cvg_incr_wcf_alwd_amt       =>  p_mx_cvg_incr_wcf_alwd_amt
      ,p_mx_cvg_mlt_incr_num            =>  p_mx_cvg_mlt_incr_num
      ,p_mx_cvg_mlt_incr_wcf_num        =>  p_mx_cvg_mlt_incr_wcf_num
      ,p_mx_wtg_dt_to_use_cd            =>  p_mx_wtg_dt_to_use_cd
      ,p_mx_wtg_dt_to_use_rl            =>  p_mx_wtg_dt_to_use_rl
      ,p_mx_wtg_perd_prte_uom           =>  p_mx_wtg_perd_prte_uom
      ,p_mx_wtg_perd_prte_val           =>  p_mx_wtg_perd_prte_val
      ,p_mx_wtg_perd_rl                 =>  p_mx_wtg_perd_rl
      ,p_nip_dflt_enrt_cd               =>  p_nip_dflt_enrt_cd
      ,p_nip_dflt_enrt_det_rl           =>  p_nip_dflt_enrt_det_rl
      ,p_dpnt_adrs_rqd_flag             =>  p_dpnt_adrs_rqd_flag
      ,p_dpnt_cvg_end_dt_cd             =>  p_dpnt_cvg_end_dt_cd
      ,p_dpnt_cvg_end_dt_rl             =>  p_dpnt_cvg_end_dt_rl
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_dpnt_dob_rqd_flag              =>  p_dpnt_dob_rqd_flag
      ,p_dpnt_leg_id_rqd_flag           =>  p_dpnt_leg_id_rqd_flag
      ,p_dpnt_no_ctfn_rqd_flag          =>  p_dpnt_no_ctfn_rqd_flag
      ,p_no_mn_cvg_amt_apls_flag        =>  p_no_mn_cvg_amt_apls_flag
      ,p_no_mn_cvg_incr_apls_flag       =>  p_no_mn_cvg_incr_apls_flag
      ,p_no_mn_opts_num_apls_flag       =>  p_no_mn_opts_num_apls_flag
      ,p_no_mx_cvg_amt_apls_flag        =>  p_no_mx_cvg_amt_apls_flag
      ,p_no_mx_cvg_incr_apls_flag       =>  p_no_mx_cvg_incr_apls_flag
      ,p_no_mx_opts_num_apls_flag       =>  p_no_mx_opts_num_apls_flag
      ,p_nip_pl_uom                     =>  p_nip_pl_uom
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_nip_acty_ref_perd_cd           =>  p_nip_acty_ref_perd_cd
      ,p_nip_enrt_info_rt_freq_cd       =>  p_nip_enrt_info_rt_freq_cd
      ,p_per_cvrd_cd                    =>  p_per_cvrd_cd
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_postelcn_edit_rl               =>  p_postelcn_edit_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_prort_prtl_yr_cvg_rstrn_cd     =>  p_prort_prtl_yr_cvg_rstrn_cd
      ,p_prort_prtl_yr_cvg_rstrn_rl     =>  p_prort_prtl_yr_cvg_rstrn_rl
      ,p_prtn_elig_ovrid_alwd_flag      =>  p_prtn_elig_ovrid_alwd_flag
      ,p_svgs_pl_flag                   =>  p_svgs_pl_flag
      ,p_subj_to_imptd_incm_typ_cd      =>  p_subj_to_imptd_incm_typ_cd
      ,p_use_all_asnts_elig_flag        =>  p_use_all_asnts_elig_flag
      ,p_use_all_asnts_for_rt_flag      =>  p_use_all_asnts_for_rt_flag
      ,p_vstg_apls_flag                 =>  p_vstg_apls_flag
      ,p_wvbl_flag                      =>  p_wvbl_flag
      ,p_hc_svc_typ_cd                  =>  p_hc_svc_typ_cd
      ,p_pl_stat_cd                     =>  p_pl_stat_cd
      ,p_prmry_fndg_mthd_cd             =>  p_prmry_fndg_mthd_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_bnf_dsgn_cd                    =>  p_bnf_dsgn_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_pl_opt_flag               =>  p_enrt_pl_opt_flag
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_may_enrl_pl_n_oipl_flag        =>  p_may_enrl_pl_n_oipl_flag
      ,p_enrt_rl                        =>  p_enrt_rl
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_alws_unrstrctd_enrt_flag       =>  p_alws_unrstrctd_enrt_flag
      ,p_bnft_or_option_rstrctn_cd      =>  p_bnft_or_option_rstrctn_cd
      ,p_cvg_incr_r_decr_only_cd        =>  p_cvg_incr_r_decr_only_cd
      ,p_unsspnd_enrt_cd                =>  p_unsspnd_enrt_cd
      ,p_pln_attribute_category         =>  p_pln_attribute_category
      ,p_pln_attribute1                 =>  p_pln_attribute1
      ,p_pln_attribute2                 =>  p_pln_attribute2
      ,p_pln_attribute3                 =>  p_pln_attribute3
      ,p_pln_attribute4                 =>  p_pln_attribute4
      ,p_pln_attribute5                 =>  p_pln_attribute5
      ,p_pln_attribute6                 =>  p_pln_attribute6
      ,p_pln_attribute7                 =>  p_pln_attribute7
      ,p_pln_attribute8                 =>  p_pln_attribute8
      ,p_pln_attribute9                 =>  p_pln_attribute9
      ,p_pln_attribute10                =>  p_pln_attribute10
      ,p_pln_attribute11                =>  p_pln_attribute11
      ,p_pln_attribute12                =>  p_pln_attribute12
      ,p_pln_attribute13                =>  p_pln_attribute13
      ,p_pln_attribute14                =>  p_pln_attribute14
      ,p_pln_attribute15                =>  p_pln_attribute15
      ,p_pln_attribute16                =>  p_pln_attribute16
      ,p_pln_attribute17                =>  p_pln_attribute17
      ,p_pln_attribute18                =>  p_pln_attribute18
      ,p_pln_attribute19                =>  p_pln_attribute19
      ,p_pln_attribute20                =>  p_pln_attribute20
      ,p_pln_attribute21                =>  p_pln_attribute21
      ,p_pln_attribute22                =>  p_pln_attribute22
      ,p_pln_attribute23                =>  p_pln_attribute23
      ,p_pln_attribute24                =>  p_pln_attribute24
      ,p_pln_attribute25                =>  p_pln_attribute25
      ,p_pln_attribute26                =>  p_pln_attribute26
      ,p_pln_attribute27                =>  p_pln_attribute27
      ,p_pln_attribute28                =>  p_pln_attribute28
      ,p_pln_attribute29                =>  p_pln_attribute29
      ,p_pln_attribute30                =>  p_pln_attribute30
      ,p_susp_if_ctfn_not_prvd_flag     =>  p_susp_if_ctfn_not_prvd_flag
      ,p_ctfn_determine_cd              =>  p_ctfn_determine_cd
      ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_susp_if_dpnt_ssn_nt_prv_cd
      ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_susp_if_dpnt_dob_nt_prv_cd
      ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_susp_if_dpnt_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_dpnt_flag     =>  p_susp_if_ctfn_not_dpnt_flag
      ,p_susp_if_bnf_ssn_nt_prv_cd      =>  p_susp_if_bnf_ssn_nt_prv_cd
      ,p_susp_if_bnf_dob_nt_prv_cd      =>  p_susp_if_bnf_dob_nt_prv_cd
      ,p_susp_if_bnf_adr_nt_prv_cd      =>  p_susp_if_bnf_adr_nt_prv_cd
      ,p_susp_if_ctfn_not_bnf_flag      =>  p_susp_if_ctfn_not_bnf_flag
      ,p_dpnt_ctfn_determine_cd         =>  p_dpnt_ctfn_determine_cd
      ,p_bnf_ctfn_determine_cd          =>  p_bnf_ctfn_determine_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_vrfy_fmly_mmbr_cd              =>  p_vrfy_fmly_mmbr_cd
      ,p_vrfy_fmly_mmbr_rl              =>  p_vrfy_fmly_mmbr_rl
      ,p_alws_tmpry_id_crd_flag         =>  p_alws_tmpry_id_crd_flag
      ,p_nip_dflt_flag                  =>  p_nip_dflt_flag
      ,p_frfs_distr_mthd_cd             =>  p_frfs_distr_mthd_cd
      ,p_frfs_distr_mthd_rl             =>  p_frfs_distr_mthd_rl
      ,p_frfs_cntr_det_cd               =>  p_frfs_cntr_det_cd
      ,p_frfs_distr_det_cd              =>  p_frfs_distr_det_cd
      ,p_cost_alloc_keyflex_1_id        =>  p_cost_alloc_keyflex_1_id
      ,p_cost_alloc_keyflex_2_id        =>  p_cost_alloc_keyflex_2_id
      ,p_post_to_gl_flag                =>  p_post_to_gl_flag
      ,p_frfs_val_det_cd                =>  p_frfs_val_det_cd
      ,p_frfs_mx_cryfwd_val             =>  p_frfs_mx_cryfwd_val
      ,p_frfs_portion_det_cd            =>  p_frfs_portion_det_cd
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup           =>  p_legislation_subgroup
      ,p_group_pl_id                    =>  p_group_pl_id
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_function_code                  =>  p_function_code
      ,p_pl_yr_not_applcbl_flag         =>  p_pl_yr_not_applcbl_flag
      ,p_use_csd_rsd_prccng_cd          =>  p_use_csd_rsd_prccng_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Plan
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
    ROLLBACK TO update_Plan;
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
    ROLLBACK TO update_Plan;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_Plan;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan
  (p_validate                       in  boolean  default false
  ,p_pl_id                          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan';
  l_object_version_number ben_pl_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Plan;
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
    -- Start of API User Hook for the before hook of delete_Plan
    --
    ben_Plan_bk3.delete_Plan_b
      (
       p_pl_id                          =>  p_pl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Plan
    --
  end;
  --
  ben_pln_del.del
    (
     p_pl_id                         => p_pl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Plan
    --
    ben_Plan_bk3.delete_Plan_a
      (p_pl_id                          =>  p_pl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Plan
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
    ROLLBACK TO delete_Plan;
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
    ROLLBACK TO delete_Plan;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_Plan;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
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
  ben_pln_shd.lck
    (p_pl_id                 => p_pl_id
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    ,p_object_version_number => p_object_version_number
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Plan_api;

/
