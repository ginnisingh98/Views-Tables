--------------------------------------------------------
--  DDL for Package BEN_PLN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLN_UPD" AUTHID CURRENT_USER as
/* $Header: beplnrhi.pkh 120.2.12010000.1 2008/07/29 12:51:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	ben_pln_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pl_id                        in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_alws_qdro_flag               in varchar2         default hr_api.g_varchar2,
  p_alws_qmcso_flag              in varchar2         default hr_api.g_varchar2,
  p_alws_reimbmts_flag           in varchar2         default hr_api.g_varchar2,
  p_bnf_addl_instn_txt_alwd_flag in varchar2         default hr_api.g_varchar2,
  p_bnf_adrs_rqd_flag            in varchar2         default hr_api.g_varchar2,
  p_bnf_cntngt_bnfs_alwd_flag    in varchar2         default hr_api.g_varchar2,
  p_bnf_ctfn_rqd_flag            in varchar2         default hr_api.g_varchar2,
  p_bnf_dob_rqd_flag             in varchar2         default hr_api.g_varchar2,
  p_bnf_dsge_mnr_ttee_rqd_flag   in varchar2         default hr_api.g_varchar2,
  p_bnf_incrmt_amt               in number           default hr_api.g_number,
  p_bnf_dflt_bnf_cd              in varchar2         default hr_api.g_varchar2,
  p_bnf_legv_id_rqd_flag         in varchar2         default hr_api.g_varchar2,
  p_bnf_may_dsgt_org_flag        in varchar2         default hr_api.g_varchar2,
  p_bnf_mn_dsgntbl_amt           in number           default hr_api.g_number,
  p_bnf_mn_dsgntbl_pct_val       in number           default hr_api.g_number,
  p_rqd_perd_enrt_nenrt_val       in number           default hr_api.g_number,
  p_ordr_num       in number           default hr_api.g_number,
  p_bnf_pct_incrmt_val           in number           default hr_api.g_number,
  p_bnf_pct_amt_alwd_cd          in varchar2         default hr_api.g_varchar2,
  p_bnf_qdro_rl_apls_flag        in varchar2         default hr_api.g_varchar2,
  p_dflt_to_asn_pndg_ctfn_cd     in varchar2         default hr_api.g_varchar2,
  p_dflt_to_asn_pndg_ctfn_rl     in number           default hr_api.g_number,
  p_drvbl_fctr_apls_rts_flag     in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_prtn_elig_flag    in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default hr_api.g_varchar2,
  p_elig_apls_flag               in varchar2         default hr_api.g_varchar2,
  p_invk_dcln_prtn_pl_flag       in varchar2         default hr_api.g_varchar2,
  p_invk_flx_cr_pl_flag          in varchar2         default hr_api.g_varchar2,
  p_imptd_incm_calc_cd           in varchar2         default hr_api.g_varchar2,
  p_drvbl_dpnt_elig_flag         in varchar2         default hr_api.g_varchar2,
  p_trk_inelig_per_flag          in varchar2         default hr_api.g_varchar2,
  p_pl_cd                        in varchar2         default hr_api.g_varchar2,
  p_auto_enrt_mthd_rl            in number           default hr_api.g_number,
  p_ivr_ident                    in varchar2         default hr_api.g_varchar2,
  p_url_ref_name                 in varchar2         default hr_api.g_varchar2,
  p_cmpr_clms_to_cvg_or_bal_cd   in varchar2         default hr_api.g_varchar2,
  p_cobra_pymt_due_dy_num        in number           default hr_api.g_number,
  p_dpnt_cvd_by_othr_apls_flag   in varchar2         default hr_api.g_varchar2,
  p_enrt_mthd_cd                 in varchar2         default hr_api.g_varchar2,
  p_enrt_cd                      in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_frfs_aply_flag               in varchar2         default hr_api.g_varchar2,
  p_hc_pl_subj_hcfa_aprvl_flag   in varchar2         default hr_api.g_varchar2,
  p_hghly_cmpd_rl_apls_flag      in varchar2         default hr_api.g_varchar2,
  p_incptn_dt                    in date             default hr_api.g_date,
  p_mn_cvg_rl                    in number           default hr_api.g_number,
  p_mn_cvg_rqd_amt               in number           default hr_api.g_number,
  p_mn_opts_rqd_num              in number           default hr_api.g_number,
  p_mx_cvg_alwd_amt              in number           default hr_api.g_number,
  p_mx_cvg_rl                    in number           default hr_api.g_number,
  p_mx_opts_alwd_num             in number           default hr_api.g_number,
  p_mx_cvg_wcfn_mlt_num          in number           default hr_api.g_number,
  p_mx_cvg_wcfn_amt              in number           default hr_api.g_number,
  p_mx_cvg_incr_alwd_amt         in number           default hr_api.g_number,
  p_mx_cvg_incr_wcf_alwd_amt     in number           default hr_api.g_number,
  p_mx_cvg_mlt_incr_num          in number           default hr_api.g_number,
  p_mx_cvg_mlt_incr_wcf_num      in number           default hr_api.g_number,
  p_mx_wtg_dt_to_use_cd          in varchar2         default hr_api.g_varchar2,
  p_mx_wtg_dt_to_use_rl          in number           default hr_api.g_number,
  p_mx_wtg_perd_prte_uom         in varchar2         default hr_api.g_varchar2,
  p_mx_wtg_perd_prte_val         in number           default hr_api.g_number,
  p_mx_wtg_perd_rl               in number           default hr_api.g_number,
  p_nip_dflt_enrt_cd             in varchar2         default hr_api.g_varchar2,
  p_nip_dflt_enrt_det_rl         in number           default hr_api.g_number,
  p_dpnt_adrs_rqd_flag           in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_dpnt_dob_rqd_flag            in varchar2         default hr_api.g_varchar2,
  p_dpnt_leg_id_rqd_flag         in varchar2         default hr_api.g_varchar2,
  p_dpnt_no_ctfn_rqd_flag        in varchar2         default hr_api.g_varchar2,
  p_no_mn_cvg_amt_apls_flag      in varchar2         default hr_api.g_varchar2,
  p_no_mn_cvg_incr_apls_flag     in varchar2         default hr_api.g_varchar2,
  p_no_mn_opts_num_apls_flag     in varchar2         default hr_api.g_varchar2,
  p_no_mx_cvg_amt_apls_flag      in varchar2         default hr_api.g_varchar2,
  p_no_mx_cvg_incr_apls_flag     in varchar2         default hr_api.g_varchar2,
  p_no_mx_opts_num_apls_flag     in varchar2         default hr_api.g_varchar2,
  p_nip_pl_uom                   in varchar2         default hr_api.g_varchar2,
  p_rqd_perd_enrt_nenrt_uom                   in varchar2         default hr_api.g_varchar2,
  p_nip_acty_ref_perd_cd         in varchar2         default hr_api.g_varchar2,
  p_nip_enrt_info_rt_freq_cd     in varchar2         default hr_api.g_varchar2,
  p_per_cvrd_cd                  in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_postelcn_edit_rl             in number           default hr_api.g_number,
  p_enrt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_prort_prtl_yr_cvg_rstrn_cd   in varchar2         default hr_api.g_varchar2,
  p_prort_prtl_yr_cvg_rstrn_rl   in number           default hr_api.g_number,
  p_prtn_elig_ovrid_alwd_flag    in varchar2         default hr_api.g_varchar2,
  p_svgs_pl_flag                 in varchar2         default hr_api.g_varchar2,
  p_subj_to_imptd_incm_typ_cd    in varchar2         default hr_api.g_varchar2,
  p_use_all_asnts_elig_flag      in varchar2         default hr_api.g_varchar2,
  p_use_all_asnts_for_rt_flag    in varchar2         default hr_api.g_varchar2,
  p_vstg_apls_flag               in varchar2         default hr_api.g_varchar2,
  p_wvbl_flag                    in varchar2         default hr_api.g_varchar2,
  p_hc_svc_typ_cd                in varchar2         default hr_api.g_varchar2,
  p_pl_stat_cd                   in varchar2         default hr_api.g_varchar2,
  p_prmry_fndg_mthd_cd           in varchar2         default hr_api.g_varchar2,
  p_rt_end_dt_cd                 in varchar2         default hr_api.g_varchar2,
  p_rt_end_dt_rl                 in number           default hr_api.g_number,
  p_rt_strt_dt_rl                in number           default hr_api.g_number,
  p_rt_strt_dt_cd                in varchar2         default hr_api.g_varchar2,
  p_bnf_dsgn_cd                  in varchar2         default hr_api.g_varchar2,
  p_pl_typ_id                    in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_enrt_pl_opt_flag             in varchar2         default hr_api.g_varchar2,
  p_bnft_prvdr_pool_id           in number           default hr_api.g_number,
  p_mAY_ENRL_PL_N_OIPL_FLAG      in VARCHAR2         default hr_api.g_varchar2,
  p_ENRT_RL                      in NUMBER           default hr_api.g_NUMBER,
  p_rqd_perd_enrt_nenrt_rl                      in NUMBER           default hr_api.g_NUMBER,
  p_ALWS_UNRSTRCTD_ENRT_FLAG     in VARCHAR2         default hr_api.g_VARCHAR2,
  p_BNFT_OR_OPTION_RSTRCTN_CD    in VARCHAR2         default hr_api.g_VARCHAR2,
  p_CVG_INCR_R_DECR_ONLY_CD      in VARCHAR2         default hr_api.g_VARCHAR2,
  p_unsspnd_enrt_cd              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pln_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pln_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute21              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute22              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute23              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute24              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute25              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute26              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute27              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute28              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute29              in varchar2         default hr_api.g_varchar2,
  p_pln_attribute30              in varchar2         default hr_api.g_varchar2,
  p_susp_if_ctfn_not_prvd_flag     in  varchar2  default hr_api.g_varchar2,
  p_ctfn_determine_cd              in  varchar2  default hr_api.g_varchar2,
  p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2  default hr_api.g_varchar2,
  p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2  default hr_api.g_varchar2,
  p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2  default hr_api.g_varchar2,
  p_susp_if_ctfn_not_dpnt_flag     in  varchar2  default hr_api.g_varchar2,
  p_susp_if_bnf_ssn_nt_prv_cd      in  varchar2  default hr_api.g_varchar2,
  p_susp_if_bnf_dob_nt_prv_cd      in  varchar2  default hr_api.g_varchar2,
  p_susp_if_bnf_adr_nt_prv_cd      in  varchar2  default hr_api.g_varchar2,
  p_susp_if_ctfn_not_bnf_flag      in  varchar2  default hr_api.g_varchar2,
  p_dpnt_ctfn_determine_cd         in  varchar2  default hr_api.g_varchar2,
  p_bnf_ctfn_determine_cd          in  varchar2  default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_actl_prem_id                 in number           default hr_api.g_number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2,
  p_vrfy_fmly_mmbr_cd            in varchar2         default hr_api.g_varchar2,
  p_vrfy_fmly_mmbr_rl            in number           default hr_api.g_number,
  p_ALWS_TMPRY_ID_CRD_FLAG       in VARCHAR2         default hr_api.g_VARCHAR2,
  p_nip_dflt_flag                in varchar2         default hr_api.g_varchar2,
  p_frfs_distr_mthd_cd           in  varchar2  default hr_api.g_varchar2,
  p_frfs_distr_mthd_rl           in  number    default hr_api.g_number,
  p_frfs_cntr_det_cd             in  varchar2  default hr_api.g_varchar2,
  p_frfs_distr_det_cd            in  varchar2  default hr_api.g_varchar2,
  p_cost_alloc_keyflex_1_id      in  number    default hr_api.g_number,
  p_cost_alloc_keyflex_2_id      in  number    default hr_api.g_number,
  p_post_to_gl_flag              in  varchar2  default hr_api.g_varchar2,
  p_frfs_val_det_cd              in  varchar2  default hr_api.g_varchar2,
  p_frfs_mx_cryfwd_val           in  number    default hr_api.g_number,
  p_frfs_portion_det_cd          in  varchar2  default hr_api.g_varchar2,
  p_bndry_perd_cd                in  varchar2  default hr_api.g_varchar2,
  p_short_name                   in  varchar2  default hr_api.g_varchar2 ,
  p_short_code                   in  varchar2  default hr_api.g_varchar2,
  p_legislation_code             in  varchar2  default hr_api.g_varchar2,
  p_legislation_subgroup         in  varchar2  default hr_api.g_varchar2,
  p_group_pl_id                  in  number    default hr_api.g_number,
  p_mapping_table_name           in  varchar2  default hr_api.g_varchar2,
  p_mapping_table_pk_id          in  number    default hr_api.g_number,
  p_function_code                in  varchar2  default hr_api.g_varchar2,
  p_pl_yr_not_applcbl_flag       in  varchar2  default hr_api.g_varchar2,
  p_use_csd_rsd_prccng_cd        in  VARCHAR2  default hr_api.g_varchar2
  );
--
end ben_pln_upd;

/
