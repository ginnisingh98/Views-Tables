--------------------------------------------------------
--  DDL for Package BEN_ABR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABR_UPD" AUTHID CURRENT_USER as
/* $Header: beabrrhi.pkh 120.7 2008/05/15 06:23:00 pvelvano noship $ */
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
  p_rec			in out nocopy 	ben_abr_shd.g_rec_type,
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
  p_acty_base_rt_id              in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_ordr_num			 in number           default hr_api.g_number,
  p_acty_typ_cd                  in varchar2         default hr_api.g_varchar2,
  p_sub_acty_typ_cd              in varchar2         default hr_api.g_varchar2,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_tx_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_use_to_calc_net_flx_cr_flag  in varchar2         default hr_api.g_varchar2,
  p_asn_on_enrt_flag             in varchar2         default hr_api.g_varchar2,
  p_abv_mx_elcn_val_alwd_flag    in varchar2         default hr_api.g_varchar2,
  p_blw_mn_elcn_alwd_flag        in varchar2         default hr_api.g_varchar2,
  p_dsply_on_enrt_flag           in varchar2         default hr_api.g_varchar2,
  p_parnt_chld_cd                in varchar2         default hr_api.g_varchar2,
  p_use_calc_acty_bs_rt_flag     in varchar2         default hr_api.g_varchar2,
  p_uses_ded_sched_flag          in varchar2         default hr_api.g_varchar2,
  p_uses_varbl_rt_flag           in varchar2         default hr_api.g_varchar2,
  p_vstg_sched_apls_flag         in varchar2         default hr_api.g_varchar2,
  p_rt_mlt_cd                    in varchar2         default hr_api.g_varchar2,
  p_proc_each_pp_dflt_flag       in varchar2         default hr_api.g_varchar2,
  p_prdct_flx_cr_when_elig_flag  in varchar2         default hr_api.g_varchar2,
  p_no_std_rt_used_flag          in varchar2         default hr_api.g_varchar2,
  p_rcrrg_cd                     in varchar2         default hr_api.g_varchar2,
  p_mn_elcn_val                  in number           default hr_api.g_number,
  p_mx_elcn_val                  in number           default hr_api.g_number,
  p_lwr_lmt_val                  in number           default hr_api.g_number,
  p_lwr_lmt_calc_rl              in number           default hr_api.g_number,
  p_upr_lmt_val                  in number           default hr_api.g_number,
  p_upr_lmt_calc_rl              in number           default hr_api.g_number,
  p_ptd_comp_lvl_fctr_id         in number           default hr_api.g_number,
  p_clm_comp_lvl_fctr_id         in number           default hr_api.g_number,
  p_entr_ann_val_flag            in varchar2         default hr_api.g_varchar2,
  p_ann_mn_elcn_val              in number           default hr_api.g_number,
  p_ann_mx_elcn_val              in number           default hr_api.g_number,
  p_wsh_rl_dy_mo_num             in number           default hr_api.g_number,
  p_uses_pymt_sched_flag         in varchar2         default hr_api.g_varchar2,
  p_nnmntry_uom                  in varchar2         default hr_api.g_varchar2,
  p_val                          in number           default hr_api.g_number,
  p_incrmt_elcn_val              in number           default hr_api.g_number,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_val_ovrid_alwd_flag          in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_det_mthd_cd          in varchar2         default hr_api.g_varchar2,
  p_acty_base_rt_stat_cd         in varchar2         default hr_api.g_varchar2,
  p_procg_src_cd                 in varchar2         default hr_api.g_varchar2,
  p_dflt_val                     in number           default hr_api.g_number,
  p_dflt_flag                    in varchar2         default hr_api.g_varchar2,
  p_frgn_erg_ded_typ_cd          in varchar2         default hr_api.g_varchar2,
  p_frgn_erg_ded_name            in varchar2         default hr_api.g_varchar2,
  p_frgn_erg_ded_ident           in varchar2         default hr_api.g_varchar2,
  p_no_mx_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_det_mthd_rl          in number           default hr_api.g_number,
  p_entr_val_at_enrt_flag        in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_eff_dt_det_rl        in number           default hr_api.g_number,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_val_calc_rl                  in number           default hr_api.g_number,
  p_no_mn_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_prtl_mo_eff_dt_det_cd        in varchar2         default hr_api.g_varchar2,
  p_only_one_bal_typ_alwd_flag   in varchar2         default hr_api.g_varchar2,
  p_rt_usg_cd                    in varchar2         default hr_api.g_varchar2,
  p_prort_mn_ann_elcn_val_cd     in varchar2         default hr_api.g_varchar2,
  p_prort_mn_ann_elcn_val_rl     in number           default hr_api.g_number,
  p_prort_mx_ann_elcn_val_cd     in varchar2         default hr_api.g_varchar2,
  p_prort_mx_ann_elcn_val_rl     in number           default hr_api.g_number,
  p_one_ann_pymt_cd              in varchar2         default hr_api.g_varchar2,
  p_det_pl_ytd_cntrs_cd          in varchar2         default hr_api.g_varchar2,
  p_asmt_to_use_cd               in varchar2         default hr_api.g_varchar2,
  p_ele_rqd_flag                 in varchar2         default hr_api.g_varchar2,
  p_subj_to_imptd_incm_flag      in varchar2         default hr_api.g_varchar2,
  p_element_type_id              in number           default hr_api.g_number,
  p_input_value_id               in number           default hr_api.g_number,
  p_input_va_calc_rl             in number           default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_parnt_acty_base_rt_id        in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_opt_id                       in number           default hr_api.g_number,
  p_oiplip_id                    in number           default hr_api.g_number,
  p_plip_id                      in number           default hr_api.g_number,
  p_ptip_id                      in number           default hr_api.g_number,
  p_cmbn_plip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_opt_id             in number           default hr_api.g_number,
  p_vstg_for_acty_rt_id          in number           default hr_api.g_number,
  p_actl_prem_id                 in number           default hr_api.g_number,
  p_TTL_COMP_LVL_FCTR_ID         in number           default hr_api.g_number,
  p_COST_ALLOCATION_KEYFLEX_ID   in number           default hr_api.g_number,
  p_ALWS_CHG_CD                  in varchar2         default hr_api.g_varchar2,
  p_ele_entry_val_cd             in varchar2         default hr_api.g_varchar2,
  p_pay_rate_grade_rule_id       in number           default hr_api.g_number,
  p_rate_periodization_cd             in varchar2         default hr_api.g_varchar2,
  p_rate_periodization_rl             in number           default hr_api.g_number,
  p_mn_mx_elcn_rl 		 in number	     default hr_api.g_number,
  p_mapping_table_name		 in varchar2         default hr_api.g_varchar2,
  p_mapping_table_pk_id		 in number	     default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_context_pgm_id               in number          default hr_api.g_number,
  p_context_pl_id                in number          default hr_api.g_number,
  p_context_opt_id               in number          default hr_api.g_number,
  p_element_det_rl  		 in number	    default hr_api.g_number,
  p_currency_det_cd		 in varchar2        default hr_api.g_varchar2,
  p_abr_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_abr_attribute1               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute2               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute3               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute4               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute5               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute6               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute7               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute8               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute9               in varchar2         default hr_api.g_varchar2,
  p_abr_attribute10              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute11              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute12              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute13              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute14              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute15              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute16              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute17              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute18              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute19              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute20              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute21              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute22              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute23              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute24              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute25              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute26              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute27              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute28              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute29              in varchar2         default hr_api.g_varchar2,
  p_abr_attribute30              in varchar2         default hr_api.g_varchar2,
  p_abr_seq_num                  in  number          default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_abr_upd;

/
