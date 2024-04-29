--------------------------------------------------------
--  DDL for Package BEN_EPO_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPO_UPD" AUTHID CURRENT_USER as
/* $Header: beeporhi.pkh 120.0 2005/05/28 02:42:36 appldev noship $ */
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
  p_rec            in out nocopy     ben_epo_shd.g_rec_type,
  p_effective_date    in     date,
  p_datetrack_mode    in     varchar2
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
  p_elig_per_opt_id              in number,
  p_elig_per_id                  in number           default hr_api.g_number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_prtn_ovridn_flag             in varchar2         default hr_api.g_varchar2,
  p_prtn_ovridn_thru_dt          in date             default hr_api.g_date,
  p_no_mx_prtn_ovrid_thru_flag   in varchar2         default hr_api.g_varchar2,
  p_elig_flag                    in varchar2         default hr_api.g_varchar2,
  p_prtn_strt_dt                 in date             default hr_api.g_date,
  p_prtn_end_dt                  in date             default hr_api.g_date,
  p_wait_perd_cmpltn_date          in date             default hr_api.g_date,
  p_wait_perd_strt_dt            in date             default hr_api.g_date,
  p_prtn_ovridn_rsn_cd           in varchar2         default hr_api.g_varchar2,
  p_pct_fl_tm_val                in number           default hr_api.g_number,
  p_opt_id                       in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_rt_comp_ref_amt              in number           default hr_api.g_number,
  p_rt_cmbn_age_n_los_val        in number           default hr_api.g_number,
  p_rt_comp_ref_uom              in varchar2         default hr_api.g_varchar2,
  p_rt_age_val                   in number           default hr_api.g_number,
  p_rt_los_val                   in number           default hr_api.g_number,
  p_rt_hrs_wkd_val               in number           default hr_api.g_number,
  p_rt_hrs_wkd_bndry_perd_cd     in varchar2         default hr_api.g_varchar2,
  p_rt_age_uom                   in varchar2         default hr_api.g_varchar2,
  p_rt_los_uom                   in varchar2         default hr_api.g_varchar2,
  p_rt_pct_fl_tm_val             in number           default hr_api.g_number,
  p_rt_frz_los_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_frz_age_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_frz_cmp_lvl_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_frz_pct_fl_tm_flag        in varchar2         default hr_api.g_varchar2,
  p_rt_frz_hrs_wkd_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_frz_comb_age_and_los_flag in varchar2         default hr_api.g_varchar2,
  p_comp_ref_amt                 in number           default hr_api.g_number,
  p_cmbn_age_n_los_val           in number           default hr_api.g_number,
  p_comp_ref_uom                 in varchar2         default hr_api.g_varchar2,
  p_age_val                      in number           default hr_api.g_number,
  p_los_val                      in number           default hr_api.g_number,
  p_hrs_wkd_val                  in number           default hr_api.g_number,
  p_hrs_wkd_bndry_perd_cd        in varchar2         default hr_api.g_varchar2,
  p_age_uom                      in varchar2         default hr_api.g_varchar2,
  p_los_uom                      in varchar2         default hr_api.g_varchar2,
  p_frz_los_flag                 in varchar2         default hr_api.g_varchar2,
  p_frz_age_flag                 in varchar2         default hr_api.g_varchar2,
  p_frz_cmp_lvl_flag             in varchar2         default hr_api.g_varchar2,
  p_frz_pct_fl_tm_flag           in varchar2         default hr_api.g_varchar2,
  p_frz_hrs_wkd_flag             in varchar2         default hr_api.g_varchar2,
  p_frz_comb_age_and_los_flag    in varchar2         default hr_api.g_varchar2,
  p_ovrid_svc_dt                 in date             default hr_api.g_date,
  p_inelg_rsn_cd                 in varchar2         default hr_api.g_varchar2,
  p_once_r_cntug_cd              in varchar2         default hr_api.g_varchar2,
  p_oipl_ordr_num                in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_epo_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_epo_attribute1               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute2               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute3               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute4               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute5               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute6               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute7               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute8               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute9               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute10              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute11              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute12              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute13              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute14              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute15              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute16              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute17              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute18              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute19              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute20              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute21              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute22              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute23              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute24              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute25              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute26              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute27              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute28              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute29              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute30              in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_effective_date               in date,
  p_datetrack_mode               in varchar2
  );
--
end ben_epo_upd;

 

/
