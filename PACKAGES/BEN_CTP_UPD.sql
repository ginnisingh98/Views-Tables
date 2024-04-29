--------------------------------------------------------
--  DDL for Package BEN_CTP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTP_UPD" AUTHID CURRENT_USER as
/* $Header: bectprhi.pkh 120.0 2005/05/28 01:26:21 appldev noship $ */
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
  p_rec			in out nocopy 	ben_ctp_shd.g_rec_type,
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
  p_ptip_id                      in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_coord_cvg_for_all_pls_flag   in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_no_ctfn_rqd_flag    in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_rt_end_dt_cd                 in varchar2         default hr_api.g_varchar2,
  p_rt_strt_dt_cd                in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_dpnt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_dpnt_adrs_rqd_flag           in varchar2         default hr_api.g_varchar2,
  p_dpnt_legv_id_rqd_flag        in varchar2         default hr_api.g_varchar2,
  p_susp_if_dpnt_ssn_nt_prv_cd   in varchar2         default hr_api.g_varchar2,
  p_susp_if_dpnt_dob_nt_prv_cd   in varchar2         default hr_api.g_varchar2,
  p_susp_if_dpnt_adr_nt_prv_cd   in varchar2         default hr_api.g_varchar2,
  p_susp_if_ctfn_not_dpnt_flag   in varchar2         default hr_api.g_varchar2,
  p_dpnt_ctfn_determine_cd       in varchar2         default hr_api.g_varchar2,
  p_postelcn_edit_rl             in number           default hr_api.g_number,
  p_rt_end_dt_rl                 in number           default hr_api.g_number,
  p_rt_strt_dt_rl                in number           default hr_api.g_number,
  p_enrt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_enrt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_rqd_perd_enrt_nenrt_rl       in number           default hr_api.g_number,
  p_auto_enrt_mthd_rl            in number           default hr_api.g_number,
  p_enrt_mthd_cd                 in varchar2         default hr_api.g_varchar2,
  p_enrt_cd                      in varchar2         default hr_api.g_varchar2,
  p_enrt_rl                      in number           default hr_api.g_number,
  p_dflt_enrt_cd                 in varchar2         default hr_api.g_varchar2,
  p_dflt_enrt_det_rl             in number           default hr_api.g_number,
  p_drvbl_fctr_apls_rts_flag     in varchar2         default hr_api.g_varchar2,
  p_drvbl_fctr_prtn_elig_flag    in varchar2         default hr_api.g_varchar2,
  p_elig_apls_flag               in varchar2         default hr_api.g_varchar2,
  p_prtn_elig_ovrid_alwd_flag    in varchar2         default hr_api.g_varchar2,
  p_trk_inelig_per_flag          in varchar2         default hr_api.g_varchar2,
  p_dpnt_dob_rqd_flag            in varchar2         default hr_api.g_varchar2,
  p_crs_this_pl_typ_only_flag    in varchar2         default hr_api.g_varchar2,
  p_ptip_stat_cd                 in varchar2         default hr_api.g_varchar2,
  p_mx_cvg_alwd_amt              in number           default hr_api.g_number,
  p_mx_enrd_alwd_ovrid_num       in number           default hr_api.g_number,
  p_mn_enrd_rqd_ovrid_num        in number           default hr_api.g_number,
  p_no_mx_pl_typ_ovrid_flag      in varchar2         default hr_api.g_varchar2,
  p_ordr_num                     in number           default hr_api.g_number,
  p_prvds_cr_flag                in varchar2         default hr_api.g_varchar2,
  p_rqd_perd_enrt_nenrt_val      in number         default hr_api.g_number,
  p_rqd_perd_enrt_nenrt_tm_uom   in varchar2         default hr_api.g_varchar2,
  p_wvbl_flag                    in varchar2         default hr_api.g_varchar2,
  p_drvd_fctr_dpnt_cvg_flag      in varchar2         default hr_api.g_varchar2,
  p_no_mn_pl_typ_overid_flag     in varchar2         default hr_api.g_varchar2,
  p_sbj_to_sps_lf_ins_mx_flag    in varchar2         default hr_api.g_varchar2,
  p_sbj_to_dpnt_lf_ins_mx_flag   in varchar2         default hr_api.g_varchar2,
  p_use_to_sum_ee_lf_ins_flag    in varchar2         default hr_api.g_varchar2,
  p_per_cvrd_cd                  in varchar2         default hr_api.g_varchar2,
  p_short_name                  in varchar2         default hr_api.g_varchar2,
  p_short_code                  in varchar2         default hr_api.g_varchar2,
    p_legislation_code                  in varchar2         default hr_api.g_varchar2,
    p_legislation_subgroup                  in varchar2         default hr_api.g_varchar2,
  p_vrfy_fmly_mmbr_cd            in varchar2         default hr_api.g_varchar2,
  p_vrfy_fmly_mmbr_rl            in number           default hr_api.g_number,
  p_ivr_ident                    in varchar2         default hr_api.g_varchar2,
  p_url_ref_name                 in varchar2         default hr_api.g_varchar2,
  p_rqd_enrt_perd_tco_cd         in varchar2         default hr_api.g_varchar2,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_typ_id                    in number           default hr_api.g_number,
  p_cmbn_ptip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_opt_id             in number           default hr_api.g_number,
  p_acrs_ptip_cvg_id             in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_ctp_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute1               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute2               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute3               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute4               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute5               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute6               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute7               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute8               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute9               in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute10              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute11              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute12              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute13              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute14              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute15              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute16              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute17              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute18              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute19              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute20              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute21              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute22              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute23              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute24              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute25              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute26              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute27              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute28              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute29              in varchar2         default hr_api.g_varchar2,
  p_ctp_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_ctp_upd;

 

/
