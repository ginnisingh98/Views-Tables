--------------------------------------------------------
--  DDL for Package BEN_VPF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VPF_INS" AUTHID CURRENT_USER as
/* $Header: bevpfrhi.pkh 120.0.12010000.1 2008/07/29 13:07:58 appldev ship $ */

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
	(p_rec 			 in out nocopy ben_vpf_shd.g_rec_type,
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
  p_rec		   in out nocopy ben_vpf_shd.g_rec_type,
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
  p_vrbl_rt_prfl_id              out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_pl_typ_opt_typ_id            in number           default null,
  p_pl_id                        in number           default null,
  p_oipl_id                      in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_business_group_id            in number,
  p_acty_typ_cd                  in varchar2,
  p_rt_typ_cd                    in varchar2         default null,
  p_bnft_rt_typ_cd               in varchar2         default null,
  p_tx_typ_cd                    in varchar2,
  p_vrbl_rt_trtmt_cd             in varchar2,
  p_acty_ref_perd_cd             in varchar2,
  p_mlt_cd                       in varchar2,
  p_incrmnt_elcn_val             in number           default null,
  p_dflt_elcn_val                in number           default null,
  p_mx_elcn_val                  in number           default null,
  p_mn_elcn_val                  in number           default null,
  p_lwr_lmt_val                  in number           default null,
  p_lwr_lmt_calc_rl              in number           default null,
  p_upr_lmt_val                  in number           default null,
  p_upr_lmt_calc_rl              in number           default null,
  p_ultmt_upr_lmt                in number           default null,
  p_ultmt_lwr_lmt                in number           default null,
  p_ultmt_upr_lmt_calc_rl        in number           default null,
  p_ultmt_lwr_lmt_calc_rl        in number           default null,
  p_ann_mn_elcn_val              in number           default null,
  p_ann_mx_elcn_val              in number           default null,
  p_val                          in number           default null,
  p_name                         in varchar2,
  p_no_mn_elcn_val_dfnd_flag     in varchar2,
  p_no_mx_elcn_val_dfnd_flag     in varchar2,
  p_alwys_sum_all_cvg_flag       in varchar2,
  p_alwys_cnt_all_prtts_flag     in varchar2,
  p_val_calc_rl                  in number           default null,
  p_vrbl_rt_prfl_stat_cd         in varchar2         default null,
  p_vrbl_usg_cd                  in varchar2         default null,
  p_asmt_to_use_cd               in varchar2         default null,
  p_rndg_cd                      in varchar2         default null,
  p_rndg_rl                      in number           default null,
  p_rt_hrly_slrd_flag            in varchar2         default null,
  p_rt_pstl_cd_flag              in varchar2         default null,
  p_rt_lbr_mmbr_flag             in varchar2         default null,
  p_rt_lgl_enty_flag             in varchar2         default null,
  p_rt_benfts_grp_flag           in varchar2         default null,
  p_rt_wk_loc_flag               in varchar2         default null,
  p_rt_brgng_unit_flag           in varchar2         default null,
  p_rt_age_flag                  in varchar2         default null,
  p_rt_los_flag                  in varchar2         default null,
  p_rt_per_typ_flag              in varchar2         default null,
  p_rt_fl_tm_pt_tm_flag          in varchar2         default null,
  p_rt_ee_stat_flag              in varchar2         default null,
  p_rt_grd_flag                  in varchar2         default null,
  p_rt_pct_fl_tm_flag            in varchar2         default null,
  p_rt_asnt_set_flag             in varchar2         default null,
  p_rt_hrs_wkd_flag              in varchar2         default null,
  p_rt_comp_lvl_flag             in varchar2         default null,
  p_rt_org_unit_flag             in varchar2         default null,
  p_rt_loa_rsn_flag              in varchar2         default null,
  p_rt_pyrl_flag                 in varchar2         default null,
  p_rt_schedd_hrs_flag           in varchar2         default null,
  p_rt_py_bss_flag               in varchar2         default null,
  p_rt_prfl_rl_flag              in varchar2         default null,
  p_rt_cmbn_age_los_flag         in varchar2         default null,
  p_rt_prtt_pl_flag              in varchar2         default null,
  p_rt_svc_area_flag             in varchar2         default null,
  p_rt_ppl_grp_flag              in varchar2         default null,
  p_rt_dsbld_flag                in varchar2         default null,
  p_rt_hlth_cvg_flag             in varchar2         default null,
  p_rt_poe_flag                  in varchar2         default null,
  p_rt_ttl_cvg_vol_flag          in varchar2         default null,
  p_rt_ttl_prtt_flag             in varchar2         default null,
  p_rt_gndr_flag                 in varchar2         default null,
  p_rt_tbco_use_flag             in varchar2         default null,
  p_vpf_attribute_category       in varchar2         default null,
  p_vpf_attribute1               in varchar2         default null,
  p_vpf_attribute2               in varchar2         default null,
  p_vpf_attribute3               in varchar2         default null,
  p_vpf_attribute4               in varchar2         default null,
  p_vpf_attribute5               in varchar2         default null,
  p_vpf_attribute6               in varchar2         default null,
  p_vpf_attribute7               in varchar2         default null,
  p_vpf_attribute8               in varchar2         default null,
  p_vpf_attribute9               in varchar2         default null,
  p_vpf_attribute10              in varchar2         default null,
  p_vpf_attribute11              in varchar2         default null,
  p_vpf_attribute12              in varchar2         default null,
  p_vpf_attribute13              in varchar2         default null,
  p_vpf_attribute14              in varchar2         default null,
  p_vpf_attribute15              in varchar2         default null,
  p_vpf_attribute16              in varchar2         default null,
  p_vpf_attribute17              in varchar2         default null,
  p_vpf_attribute18              in varchar2         default null,
  p_vpf_attribute19              in varchar2         default null,
  p_vpf_attribute20              in varchar2         default null,
  p_vpf_attribute21              in varchar2         default null,
  p_vpf_attribute22              in varchar2         default null,
  p_vpf_attribute23              in varchar2         default null,
  p_vpf_attribute24              in varchar2         default null,
  p_vpf_attribute25              in varchar2         default null,
  p_vpf_attribute26              in varchar2         default null,
  p_vpf_attribute27              in varchar2         default null,
  p_vpf_attribute28              in varchar2         default null,
  p_vpf_attribute29              in varchar2         default null,
  p_vpf_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date ,
  p_rt_cntng_prtn_prfl_flag	 in varchar2         default null,
  p_rt_cbr_quald_bnf_flag  	 in varchar2         default null,
  p_rt_optd_mdcr_flag      	 in varchar2         default null,
  p_rt_lvg_rsn_flag        	 in varchar2         default null,
  p_rt_pstn_flag           	 in varchar2         default null,
  p_rt_comptncy_flag       	 in varchar2         default null,
  p_rt_job_flag            	 in varchar2         default null,
  p_rt_qual_titl_flag      	 in varchar2         default null,
  p_rt_dpnt_cvrd_pl_flag   	 in varchar2         default null,
  p_rt_dpnt_cvrd_plip_flag 	 in varchar2         default null,
  p_rt_dpnt_cvrd_ptip_flag 	 in varchar2         default null,
  p_rt_dpnt_cvrd_pgm_flag  	 in varchar2         default null,
  p_rt_enrld_oipl_flag     	 in varchar2         default null,
  p_rt_enrld_pl_flag       	 in varchar2         default null,
  p_rt_enrld_plip_flag     	 in varchar2         default null,
  p_rt_enrld_ptip_flag     	 in varchar2         default null,
  p_rt_enrld_pgm_flag      	 in varchar2         default null,
  p_rt_prtt_anthr_pl_flag  	 in varchar2         default null,
  p_rt_othr_ptip_flag      	 in varchar2         default null,
  p_rt_no_othr_cvg_flag    	 in varchar2         default null,
  p_rt_dpnt_othr_ptip_flag 	 in varchar2         default null,
  p_rt_qua_in_gr_flag            in varchar2  	     default null,
  p_rt_perf_rtng_flag 	         in varchar2  	     default null,
  p_rt_elig_prfl_flag 	         in varchar2  	     default null
  );
--
end ben_vpf_ins;

/
