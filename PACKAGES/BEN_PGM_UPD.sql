--------------------------------------------------------
--  DDL for Package BEN_PGM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_UPD" AUTHID CURRENT_USER as
/* $Header: bepgmrhi.pkh 120.0 2005/05/28 10:47:35 appldev noship $ */
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
  p_rec			in out nocopy 	ben_pgm_shd.g_rec_type,
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
  p_pgm_id                       in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_dpnt_adrs_rqd_flag           in varchar2         default hr_api.g_varchar2,
  p_pgm_prvds_no_auto_enrt_flag  in varchar2         default hr_api.g_varchar2,
  p_dpnt_dob_rqd_flag            in varchar2         default hr_api.g_varchar2,
  p_pgm_prvds_no_dflt_enrt_flag  in varchar2         default hr_api.g_varchar2,
  p_dpnt_legv_id_rqd_flag        in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_lvl_cd             in varchar2         default hr_api.g_varchar2,
  p_pgm_stat_cd                  in varchar2         default hr_api.g_varchar2,
  p_ivr_ident                    in varchar2         default hr_api.g_varchar2,
  p_pgm_typ_cd                   in varchar2         default hr_api.g_varchar2,
  p_elig_apls_flag               in varchar2         default hr_api.g_varchar2,
  p_uses_all_asmts_for_rts_flag  in varchar2         default hr_api.g_varchar2,
  p_url_ref_name                 in varchar2         default hr_api.g_varchar2,
  p_pgm_desc                     in varchar2         default hr_api.g_varchar2,
  p_prtn_elig_ovrid_alwd_flag    in varchar2         default hr_api.g_varchar2,
  p_pgm_use_all_asnts_elig_flag  in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default hr_api.g_varchar2,
  p_mx_dpnt_pct_prtt_lf_amt      in number           default hr_api.g_number,
  p_mx_sps_pct_prtt_lf_amt       in number           default hr_api.g_number,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_coord_cvg_for_all_pls_flg    in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_dpnt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_dpnt_dsgn_no_ctfn_rqd_flag   in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_dpnt_elig_flag    in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_prtn_elig_flag    in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_enrt_info_rt_freq_cd         in varchar2         default hr_api.g_varchar2,
  p_rt_strt_dt_cd                in varchar2         default hr_api.g_varchar2,
  p_rt_strt_dt_rl                in number           default hr_api.g_number,
  p_rt_end_dt_cd                 in varchar2         default hr_api.g_varchar2,
  p_rt_end_dt_rl                 in number           default hr_api.g_number,
  p_pgm_grp_cd                   in varchar2         default hr_api.g_varchar2,
  p_pgm_uom                      in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_apls_rts_flag     in varchar2         default hr_api.g_varchar2,
  p_alws_unrstrctd_enrt_flag     in varchar2         default hr_api.g_varchar2,
  p_enrt_cd                      in varchar2         default hr_api.g_varchar2,
  p_enrt_mthd_cd                 in varchar2         default hr_api.g_varchar2,
  p_poe_lvl_cd                   in varchar2         default hr_api.g_varchar2,
  p_enrt_rl                      in number           default hr_api.g_number,
  p_auto_enrt_mthd_rl            in number           default hr_api.g_number,
  p_trk_inelig_per_flag          in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_per_cvrd_cd                  in varchar2         default hr_api.g_varchar2,
  P_vrfy_fmly_mmbr_rl            in number           default hr_api.g_number,
  P_vrfy_fmly_mmbr_cd            in varchar2         default hr_api.g_varchar2,
  p_short_name			 in varchar2  	     default hr_api.g_varchar2,	--FHR
  p_short_code			 in varchar2  	     default hr_api.g_varchar2, --FHR
    p_legislation_code			 in varchar2  	     default hr_api.g_varchar2,
    p_legislation_subgroup			 in varchar2  	     default hr_api.g_varchar2,
  p_Dflt_pgm_flag                in Varchar2         default hr_api.g_varchar2,
  p_Use_prog_points_flag         in Varchar2         default hr_api.g_varchar2,
  p_Dflt_step_cd                 in Varchar2         default hr_api.g_varchar2,
  p_Dflt_step_rl                 in number           default hr_api.g_number,
  p_Update_salary_cd             in Varchar2         default hr_api.g_varchar2,
  p_Use_multi_pay_rates_flag     in Varchar2         default hr_api.g_varchar2,
  p_dflt_element_type_id         in number           default hr_api.g_number,
  p_Dflt_input_value_id          in number           default hr_api.g_number,
  p_Use_scores_cd                in Varchar2         default hr_api.g_varchar2,
  p_Scores_calc_mthd_cd          in Varchar2         default hr_api.g_varchar2,
  p_Scores_calc_rl               in number           default hr_api.g_number,
  p_gsp_allow_override_flag       in varchar2         default hr_api.g_varchar2,
  p_use_variable_rates_flag       in varchar2         default hr_api.g_varchar2,
  p_salary_calc_mthd_cd       in varchar2         default hr_api.g_varchar2,
  p_salary_calc_mthd_rl       in number         default hr_api.g_number,
  p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default hr_api.g_varchar2,
  p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default hr_api.g_varchar2,
  p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default hr_api.g_varchar2,
  p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default hr_api.g_varchar2,
  p_dpnt_ctfn_determine_cd          in  varchar2   default hr_api.g_varchar2,
  p_pgm_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute21              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute22              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute23              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute24              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute25              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute26              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute27              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute28              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute29              in varchar2         default hr_api.g_varchar2,
  p_pgm_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_pgm_upd;

 

/
