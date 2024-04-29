--------------------------------------------------------
--  DDL for Package BEN_ELP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELP_UPD" AUTHID CURRENT_USER as
/* $Header: beelprhi.pkh 120.1.12000000.1 2007/01/19 05:29:30 appldev noship $ */
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
  p_rec			in out nocopy 	ben_elp_shd.g_rec_type,
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
  p_eligy_prfl_id                in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_stat_cd                      in varchar2         default hr_api.g_varchar2,
  p_asmt_to_use_cd               in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_plip_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_cbr_quald_bnf_flag      in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_ptip_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_plip_flag     in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_ptip_flag     in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_pgm_flag      in varchar2         default hr_api.g_varchar2,
  p_elig_job_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_hrly_slrd_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_pstl_cd_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_lbr_mmbr_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_lgl_enty_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_benfts_grp_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_wk_loc_flag             in varchar2         default hr_api.g_varchar2,
  p_elig_brgng_unit_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_age_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_los_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_per_typ_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_fl_tm_pt_tm_flag        in varchar2         default hr_api.g_varchar2,
  p_elig_ee_stat_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_grd_flag                in varchar2         default hr_api.g_varchar2,
  p_elig_pct_fl_tm_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_asnt_set_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_hrs_wkd_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_comp_lvl_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_org_unit_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_loa_rsn_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_pyrl_flag               in varchar2         default hr_api.g_varchar2,
  p_elig_schedd_hrs_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_py_bss_flag             in varchar2         default hr_api.g_varchar2,
  p_eligy_prfl_rl_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_cmbn_age_los_flag       in varchar2         default hr_api.g_varchar2,
  p_cntng_prtn_elig_prfl_flag    in varchar2         default hr_api.g_varchar2,
  p_elig_prtt_pl_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_ppl_grp_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_svc_area_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_ptip_prte_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_no_othr_cvg_flag        in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_pl_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_oipl_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_enrld_pgm_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_cvrd_pl_flag       in varchar2         default hr_api.g_varchar2,
  p_elig_lvg_rsn_flag            in varchar2         default hr_api.g_varchar2,
  p_elig_optd_mdcr_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_tbco_use_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_dpnt_othr_ptip_flag     in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_elp_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_elp_attribute1               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute2               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute3               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute4               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute5               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute6               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute7               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute8               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute9               in varchar2         default hr_api.g_varchar2,
  p_elp_attribute10              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute11              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute12              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute13              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute14              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute15              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute16              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute17              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute18              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute19              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute20              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute21              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute22              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute23              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute24              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute25              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute26              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute27              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute28              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute29              in varchar2         default hr_api.g_varchar2,
  p_elp_attribute30              in varchar2         default hr_api.g_varchar2,
  p_elig_mrtl_sts_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_gndr_flag               in varchar2         default hr_api.g_varchar2,
  p_elig_dsblty_ctg_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_dsblty_rsn_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_dsblty_dgr_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_suppl_role_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_qual_titl_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_pstn_flag               in varchar2         default hr_api.g_varchar2,
  p_elig_prbtn_perd_flag         in varchar2         default hr_api.g_varchar2,
  p_elig_sp_clng_prg_pt_flag     in varchar2         default hr_api.g_varchar2,
  p_bnft_cagr_prtn_cd            in varchar2         default hr_api.g_varchar2,
  p_elig_dsbld_flag              in varchar2         default hr_api.g_varchar2,
  p_elig_ttl_cvg_vol_flag        in varchar2         default hr_api.g_varchar2,
  p_elig_ttl_prtt_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_comptncy_flag           in varchar2         default hr_api.g_varchar2,
  p_elig_hlth_cvg_flag  	 in varchar2         default hr_api.g_varchar2,
  p_elig_anthr_pl_flag  	 in varchar2         default hr_api.g_varchar2,
  p_elig_qua_in_gr_flag		 in varchar2         default hr_api.g_varchar2,
  p_elig_perf_rtng_flag		 in varchar2         default hr_api.g_varchar2,
  p_elig_crit_values_flag        in varchar2         default hr_api.g_varchar2,  /* RBC */
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_elp_upd;

 

/
