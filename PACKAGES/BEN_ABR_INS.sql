--------------------------------------------------------
--  DDL for Package BEN_ABR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABR_INS" AUTHID CURRENT_USER as
/* $Header: beabrrhi.pkh 120.7 2008/05/15 06:23:00 pvelvano noship $ */

--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_abr_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) We must lock parent rows (if any exist).
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (
  p_rec		   in out nocopy ben_abr_shd.g_rec_type,
  p_effective_date in     date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_acty_base_rt_id              out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_ordr_num			 in number           default null,
  p_acty_typ_cd                  in varchar2         default null,
  p_sub_acty_typ_cd              in varchar2         default null,
  p_name                         in varchar2         default null,
  p_rt_typ_cd                    in varchar2         default null,
  p_bnft_rt_typ_cd               in varchar2         default null,
  p_tx_typ_cd                    in varchar2         default null,
  p_use_to_calc_net_flx_cr_flag  in varchar2         default 'N',
  p_asn_on_enrt_flag             in varchar2         default 'N',
  p_abv_mx_elcn_val_alwd_flag    in varchar2         default 'N',
  p_blw_mn_elcn_alwd_flag        in varchar2         default 'N',
  p_dsply_on_enrt_flag           in varchar2         default 'N',
  p_parnt_chld_cd                in varchar2         default null,
  p_use_calc_acty_bs_rt_flag     in varchar2         default 'Y',
  p_uses_ded_sched_flag          in varchar2         default 'N',
  p_uses_varbl_rt_flag           in varchar2         default 'N',
  p_vstg_sched_apls_flag         in varchar2         default 'N',
  p_rt_mlt_cd                    in varchar2         default null,
  p_proc_each_pp_dflt_flag       in varchar2         default 'N',
  p_prdct_flx_cr_when_elig_flag  in varchar2         default 'N',
  p_no_std_rt_used_flag          in varchar2         default 'N',
  p_rcrrg_cd                     in varchar2         default null,
  p_mn_elcn_val                  in number           default null,
  p_mx_elcn_val                  in number           default null,
  p_lwr_lmt_val                  in number           default null,
  p_lwr_lmt_calc_rl              in number           default null,
  p_upr_lmt_val                  in number           default null,
  p_upr_lmt_calc_rl              in number           default null,
  p_ptd_comp_lvl_fctr_id         in number           default null,
  p_clm_comp_lvl_fctr_id         in number           default null,
  p_entr_ann_val_flag            in varchar2         default 'N',
  p_ann_mn_elcn_val              in number           default null,
  p_ann_mx_elcn_val              in number           default null,
  p_wsh_rl_dy_mo_num             in number           default null,
  p_uses_pymt_sched_flag         in varchar2         default 'N',
  p_nnmntry_uom                  in varchar2         default null,
  p_val                          in number           default null,
  p_incrmt_elcn_val              in number           default null,
  p_rndg_cd                      in varchar2         default null,
  p_val_ovrid_alwd_flag          in varchar2         default 'N',
  p_prtl_mo_det_mthd_cd          in varchar2         default null,
  p_acty_base_rt_stat_cd         in varchar2         default null,
  p_procg_src_cd                 in varchar2         default null,
  p_dflt_val                     in number           default null,
  p_dflt_flag                    in varchar2,
  p_frgn_erg_ded_typ_cd          in varchar2         default null,
  p_frgn_erg_ded_name            in varchar2         default null,
  p_frgn_erg_ded_ident           in varchar2         default null,
  p_no_mx_elcn_val_dfnd_flag     in varchar2         default 'N',
  p_prtl_mo_det_mthd_rl          in number           default null,
  p_entr_val_at_enrt_flag        in varchar2         default 'N',
  p_prtl_mo_eff_dt_det_rl        in number           default null,
  p_rndg_rl                      in number           default null,
  p_val_calc_rl                  in number           default null,
  p_no_mn_elcn_val_dfnd_flag     in varchar2         default 'N',
  p_prtl_mo_eff_dt_det_cd        in varchar2         default null,
  p_only_one_bal_typ_alwd_flag   in varchar2         default 'N',
  p_rt_usg_cd                    in varchar2         default null,
  p_prort_mn_ann_elcn_val_cd     in varchar2         default null,
  p_prort_mn_ann_elcn_val_rl     in number           default null,
  p_prort_mx_ann_elcn_val_cd     in varchar2         default null,
  p_prort_mx_ann_elcn_val_rl     in number           default null,
  p_one_ann_pymt_cd              in varchar2         default null,
  p_det_pl_ytd_cntrs_cd          in varchar2         default null,
  p_asmt_to_use_cd               in varchar2         default null,
  p_ele_rqd_flag                 in varchar2         default 'Y',
  p_subj_to_imptd_incm_flag      in varchar2         default 'N',
  p_element_type_id              in number           default null,
  p_input_value_id               in number           default null,
  p_input_va_calc_rl             in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_parnt_acty_base_rt_id        in number           default null,
  p_pgm_id                       in number           default null,
  p_pl_id                        in number           default null,
  p_oipl_id                      in number           default null,
  p_opt_id                       in number           default null,
  p_oiplip_id                    in number           default null,
  p_plip_id                      in number           default null,
  p_ptip_id                      in number           default null,
  p_cmbn_plip_id                 in number           default null,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_vstg_for_acty_rt_id          in number           default null,
  p_actl_prem_id                 in number           default null,
  p_TTL_COMP_LVL_FCTR_ID         in number           default null,
  p_COST_ALLOCATION_KEYFLEX_ID   in number           default null,
  p_ALWS_CHG_CD                  in varchar2         default null,
  p_ele_entry_val_cd             in varchar2         default null,
  p_pay_rate_grade_rule_id       in number           default null,
  p_rate_periodization_cd             in varchar2         default null,
  p_rate_periodization_rl             in number           default null,
  p_mn_mx_elcn_rl 		 in number          default null,
  p_mapping_table_name		 in varchar2         default null,
  p_mapping_table_pk_id		 in number           default null,
  p_business_group_id            in number,
  p_context_pgm_id               in number          default null,
  p_context_pl_id                in number          default null,
  p_context_opt_id               in number          default null,
  p_element_det_rl               in number          default null,
  p_currency_det_cd              in varchar2        default null,
  p_abr_attribute_category       in varchar2         default null,
  p_abr_attribute1               in varchar2         default null,
  p_abr_attribute2               in varchar2         default null,
  p_abr_attribute3               in varchar2         default null,
  p_abr_attribute4               in varchar2         default null,
  p_abr_attribute5               in varchar2         default null,
  p_abr_attribute6               in varchar2         default null,
  p_abr_attribute7               in varchar2         default null,
  p_abr_attribute8               in varchar2         default null,
  p_abr_attribute9               in varchar2         default null,
  p_abr_attribute10              in varchar2         default null,
  p_abr_attribute11              in varchar2         default null,
  p_abr_attribute12              in varchar2         default null,
  p_abr_attribute13              in varchar2         default null,
  p_abr_attribute14              in varchar2         default null,
  p_abr_attribute15              in varchar2         default null,
  p_abr_attribute16              in varchar2         default null,
  p_abr_attribute17              in varchar2         default null,
  p_abr_attribute18              in varchar2         default null,
  p_abr_attribute19              in varchar2         default null,
  p_abr_attribute20              in varchar2         default null,
  p_abr_attribute21              in varchar2         default null,
  p_abr_attribute22              in varchar2         default null,
  p_abr_attribute23              in varchar2         default null,
  p_abr_attribute24              in varchar2         default null,
  p_abr_attribute25              in varchar2         default null,
  p_abr_attribute26              in varchar2         default null,
  p_abr_attribute27              in varchar2         default null,
  p_abr_attribute28              in varchar2         default null,
  p_abr_attribute29              in varchar2         default null,
  p_abr_attribute30              in varchar2         default null,
  p_abr_seq_num                  in  number          default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  );
--
end ben_abr_ins;

/
