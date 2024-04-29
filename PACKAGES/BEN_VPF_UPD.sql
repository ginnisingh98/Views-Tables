--------------------------------------------------------
--  DDL for Package BEN_VPF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VPF_UPD" AUTHID CURRENT_USER as
/* $Header: bevpfrhi.pkh 120.0.12010000.1 2008/07/29 13:07:58 appldev ship $ */
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
  p_rec			in out nocopy 	ben_vpf_shd.g_rec_type,
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
  p_vrbl_rt_prfl_id              in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_pl_typ_opt_typ_id            in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_acty_typ_cd                  in varchar2         default hr_api.g_varchar2,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_tx_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_vrbl_rt_trtmt_cd             in varchar2         default hr_api.g_varchar2,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_mlt_cd                       in varchar2         default hr_api.g_varchar2,
  p_incrmnt_elcn_val             in number           default hr_api.g_number,
  p_dflt_elcn_val                in number           default hr_api.g_number,
  p_mx_elcn_val                  in number           default hr_api.g_number,
  p_mn_elcn_val                  in number           default hr_api.g_number,
  p_lwr_lmt_val                  in number           default hr_api.g_number,
  p_lwr_lmt_calc_rl              in number           default hr_api.g_number,
  p_upr_lmt_val                  in number           default hr_api.g_number,
  p_upr_lmt_calc_rl              in number           default hr_api.g_number,
  p_ultmt_upr_lmt                in number           default hr_api.g_number,
  p_ultmt_lwr_lmt                in number           default hr_api.g_number,
  p_ultmt_upr_lmt_calc_rl        in number           default hr_api.g_number,
  p_ultmt_lwr_lmt_calc_rl        in number           default hr_api.g_number,
  p_ann_mn_elcn_val              in number           default hr_api.g_number,
  p_ann_mx_elcn_val              in number           default hr_api.g_number,
  p_val                          in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_no_mn_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_no_mx_elcn_val_dfnd_flag     in varchar2         default hr_api.g_varchar2,
  p_alwys_sum_all_cvg_flag       in varchar2         default hr_api.g_varchar2,
  p_alwys_cnt_all_prtts_flag     in varchar2         default hr_api.g_varchar2,
  p_val_calc_rl                  in number           default hr_api.g_number,
  p_vrbl_rt_prfl_stat_cd         in varchar2         default hr_api.g_varchar2,
  p_vrbl_usg_cd                  in varchar2         default hr_api.g_varchar2,
  p_asmt_to_use_cd               in varchar2         default hr_api.g_varchar2,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_rt_hrly_slrd_flag            in varchar2         default hr_api.g_varchar2,
  p_rt_pstl_cd_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_lbr_mmbr_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_lgl_enty_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_benfts_grp_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_wk_loc_flag               in varchar2         default hr_api.g_varchar2,
  p_rt_brgng_unit_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_age_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_los_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_per_typ_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_fl_tm_pt_tm_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_ee_stat_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_grd_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_pct_fl_tm_flag            in varchar2         default hr_api.g_varchar2,
  p_rt_asnt_set_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_hrs_wkd_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_comp_lvl_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_org_unit_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_loa_rsn_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_pyrl_flag                 in varchar2         default hr_api.g_varchar2,
  p_rt_schedd_hrs_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_py_bss_flag               in varchar2         default hr_api.g_varchar2,
  p_rt_prfl_rl_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_cmbn_age_los_flag         in varchar2         default hr_api.g_varchar2,
  p_rt_prtt_pl_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_svc_area_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_ppl_grp_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_dsbld_flag                in varchar2         default hr_api.g_varchar2,
  p_rt_hlth_cvg_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_poe_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_ttl_cvg_vol_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_ttl_prtt_flag             in varchar2         default hr_api.g_varchar2,
  p_rt_gndr_flag                 in varchar2         default hr_api.g_varchar2,
  p_rt_tbco_use_flag             in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute1               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute2               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute3               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute4               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute5               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute6               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute7               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute8               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute9               in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute10              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute11              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute12              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute13              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute14              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute15              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute16              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute17              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute18              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute19              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute20              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute21              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute22              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute23              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute24              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute25              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute26              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute27              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute28              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute29              in varchar2         default hr_api.g_varchar2,
  p_vpf_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2,
  p_rt_cntng_prtn_prfl_flag	 in varchar2         default hr_api.g_varchar2,
  p_rt_cbr_quald_bnf_flag  	 in varchar2         default hr_api.g_varchar2,
  p_rt_optd_mdcr_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_lvg_rsn_flag        	 in varchar2         default hr_api.g_varchar2,
  p_rt_pstn_flag           	 in varchar2         default hr_api.g_varchar2,
  p_rt_comptncy_flag       	 in varchar2         default hr_api.g_varchar2,
  p_rt_job_flag            	 in varchar2         default hr_api.g_varchar2,
  p_rt_qual_titl_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_pl_flag   	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_plip_flag 	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_ptip_flag 	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_cvrd_pgm_flag  	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_oipl_flag     	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_pl_flag       	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_plip_flag     	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_ptip_flag     	 in varchar2         default hr_api.g_varchar2,
  p_rt_enrld_pgm_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_prtt_anthr_pl_flag  	 in varchar2         default hr_api.g_varchar2,
  p_rt_othr_ptip_flag      	 in varchar2         default hr_api.g_varchar2,
  p_rt_no_othr_cvg_flag    	 in varchar2         default hr_api.g_varchar2,
  p_rt_dpnt_othr_ptip_flag 	 in varchar2         default hr_api.g_varchar2,
  p_rt_qua_in_gr_flag            in varchar2 	     default hr_api.g_varchar2,
  p_rt_perf_rtng_flag 	         in varchar2 	     default hr_api.g_varchar2,
  p_rt_elig_prfl_flag 	         in varchar2 	     default hr_api.g_varchar2
  );
--
end ben_vpf_upd;

/
