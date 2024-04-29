--------------------------------------------------------
--  DDL for Package BEN_ELP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELP_INS" AUTHID CURRENT_USER as
/* $Header: beelprhi.pkh 120.1.12000000.1 2007/01/19 05:29:30 appldev noship $ */

--
--|------------------------< set_base_key_value >----------------------------|
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.

procedure set_base_key_value (p_eligy_prfl_id  in  number);

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
	(p_rec 			 in out nocopy ben_elp_shd.g_rec_type,
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
  p_rec		   in out nocopy ben_elp_shd.g_rec_type,
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
  p_eligy_prfl_id                out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_description                  in varchar2         default null,
  p_stat_cd                      in varchar2,
  p_asmt_to_use_cd               in varchar2,
  p_elig_enrld_plip_flag         in varchar2,
  p_elig_cbr_quald_bnf_flag      in varchar2,
  p_elig_enrld_ptip_flag         in varchar2,
  p_elig_dpnt_cvrd_plip_flag     in varchar2,
  p_elig_dpnt_cvrd_ptip_flag     in varchar2,
  p_elig_dpnt_cvrd_pgm_flag      in varchar2,
  p_elig_job_flag                in varchar2,
  p_elig_hrly_slrd_flag          in varchar2,
  p_elig_pstl_cd_flag            in varchar2,
  p_elig_lbr_mmbr_flag           in varchar2,
  p_elig_lgl_enty_flag           in varchar2,
  p_elig_benfts_grp_flag         in varchar2,
  p_elig_wk_loc_flag             in varchar2,
  p_elig_brgng_unit_flag         in varchar2,
  p_elig_age_flag                in varchar2,
  p_elig_los_flag                in varchar2,
  p_elig_per_typ_flag            in varchar2,
  p_elig_fl_tm_pt_tm_flag        in varchar2,
  p_elig_ee_stat_flag            in varchar2,
  p_elig_grd_flag                in varchar2,
  p_elig_pct_fl_tm_flag          in varchar2,
  p_elig_asnt_set_flag           in varchar2,
  p_elig_hrs_wkd_flag            in varchar2,
  p_elig_comp_lvl_flag           in varchar2,
  p_elig_org_unit_flag           in varchar2,
  p_elig_loa_rsn_flag            in varchar2,
  p_elig_pyrl_flag               in varchar2,
  p_elig_schedd_hrs_flag         in varchar2,
  p_elig_py_bss_flag             in varchar2,
  p_eligy_prfl_rl_flag           in varchar2,
  p_elig_cmbn_age_los_flag       in varchar2,
  p_cntng_prtn_elig_prfl_flag    in varchar2,
  p_elig_prtt_pl_flag            in varchar2,
  p_elig_ppl_grp_flag            in varchar2,
  p_elig_svc_area_flag           in varchar2,
  p_elig_ptip_prte_flag          in varchar2,
  p_elig_no_othr_cvg_flag        in varchar2,
  p_elig_enrld_pl_flag           in varchar2,
  p_elig_enrld_oipl_flag         in varchar2,
  p_elig_enrld_pgm_flag          in varchar2,
  p_elig_dpnt_cvrd_pl_flag       in varchar2,
  p_elig_lvg_rsn_flag            in varchar2,
  p_elig_optd_mdcr_flag          in varchar2,
  p_elig_tbco_use_flag           in varchar2,
  p_elig_dpnt_othr_ptip_flag     in varchar2,
  p_business_group_id            in number,
  p_elp_attribute_category       in varchar2         default null,
  p_elp_attribute1               in varchar2         default null,
  p_elp_attribute2               in varchar2         default null,
  p_elp_attribute3               in varchar2         default null,
  p_elp_attribute4               in varchar2         default null,
  p_elp_attribute5               in varchar2         default null,
  p_elp_attribute6               in varchar2         default null,
  p_elp_attribute7               in varchar2         default null,
  p_elp_attribute8               in varchar2         default null,
  p_elp_attribute9               in varchar2         default null,
  p_elp_attribute10              in varchar2         default null,
  p_elp_attribute11              in varchar2         default null,
  p_elp_attribute12              in varchar2         default null,
  p_elp_attribute13              in varchar2         default null,
  p_elp_attribute14              in varchar2         default null,
  p_elp_attribute15              in varchar2         default null,
  p_elp_attribute16              in varchar2         default null,
  p_elp_attribute17              in varchar2         default null,
  p_elp_attribute18              in varchar2         default null,
  p_elp_attribute19              in varchar2         default null,
  p_elp_attribute20              in varchar2         default null,
  p_elp_attribute21              in varchar2         default null,
  p_elp_attribute22              in varchar2         default null,
  p_elp_attribute23              in varchar2         default null,
  p_elp_attribute24              in varchar2         default null,
  p_elp_attribute25              in varchar2         default null,
  p_elp_attribute26              in varchar2         default null,
  p_elp_attribute27              in varchar2         default null,
  p_elp_attribute28              in varchar2         default null,
  p_elp_attribute29              in varchar2         default null,
  p_elp_attribute30              in varchar2         default null,
  p_elig_mrtl_sts_flag           in varchar2,
  p_elig_gndr_flag               in varchar2,
  p_elig_dsblty_ctg_flag         in varchar2,
  p_elig_dsblty_rsn_flag         in varchar2,
  p_elig_dsblty_dgr_flag         in varchar2,
  p_elig_suppl_role_flag         in varchar2,
  p_elig_qual_titl_flag          in varchar2,
  p_elig_pstn_flag               in varchar2,
  p_elig_prbtn_perd_flag         in varchar2,
  p_elig_sp_clng_prg_pt_flag     in varchar2,
  p_bnft_cagr_prtn_cd            in varchar2,
  p_elig_dsbld_flag              in varchar2,
  p_elig_ttl_cvg_vol_flag        in varchar2,
  p_elig_ttl_prtt_flag           in varchar2,
  p_elig_comptncy_flag           in varchar2,
  p_elig_hlth_cvg_flag  	 in varchar2,
  p_elig_anthr_pl_flag  	 in varchar2,
  p_elig_qua_in_gr_flag		 in varchar2,
  p_elig_perf_rtng_flag		 in varchar2,
  p_elig_crit_values_flag        in varchar2,   /* RBC */
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  );
--
end ben_elp_ins;

 

/
