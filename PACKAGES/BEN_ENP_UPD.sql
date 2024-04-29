--------------------------------------------------------
--  DDL for Package BEN_ENP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENP_UPD" AUTHID CURRENT_USER as
/* $Header: beenprhi.pkh 120.1 2007/05/13 22:29:48 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
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
  p_effective_date               in date,
  p_rec        in out nocopy ben_enp_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
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
  p_effective_date               in date,
  p_enrt_perd_id                 in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_yr_perd_id                   in number           default hr_api.g_number,
  p_popl_enrt_typ_cycl_id        in number           default hr_api.g_number,
  p_end_dt                       in date             default hr_api.g_date,
  p_strt_dt                      in date             default hr_api.g_date,
  p_asnd_lf_evt_dt               in date             default hr_api.g_date,
  p_cls_enrt_dt_to_use_cd        in varchar2         default hr_api.g_varchar2,
  p_dflt_enrt_dt                 in date             default hr_api.g_date,
  p_enrt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_rt_strt_dt_rl                in number           default hr_api.g_number,
  p_enrt_cvg_end_dt_cd           in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_rl          in number           default hr_api.g_number,
  p_enrt_cvg_end_dt_rl           in number           default hr_api.g_number,
  p_procg_end_dt                 in date             default hr_api.g_date,
  p_rt_strt_dt_cd                in varchar2         default hr_api.g_varchar2,
  p_rt_end_dt_cd                 in varchar2         default hr_api.g_varchar2,
  p_rt_end_dt_rl                 in number           default hr_api.g_number,
  p_bdgt_upd_strt_dt             in  date            default hr_api.g_date,
  p_bdgt_upd_end_dt              in  date            default hr_api.g_date,
  p_ws_upd_strt_dt               in  date            default hr_api.g_date,
  p_ws_upd_end_dt                in  date            default hr_api.g_date,
  p_dflt_ws_acc_cd               in  varchar2        default hr_api.g_varchar2,
  p_prsvr_bdgt_cd                in  varchar2        default hr_api.g_varchar2,
  p_uses_bdgt_flag               in  varchar2        default hr_api.g_varchar2,
  p_auto_distr_flag              in  varchar2        default hr_api.g_varchar2,
  p_hrchy_to_use_cd              in  varchar2        default hr_api.g_varchar2,
  p_pos_structure_version_id        in  number          default hr_api.g_number,
  p_emp_interview_type_cd        in  varchar2        default hr_api.g_varchar2,
  p_wthn_yr_perd_id              in  number          default hr_api.g_number,
  p_ler_id                       in  number          default hr_api.g_number,
  p_perf_revw_strt_dt            in  date            default hr_api.g_date,
  p_asg_updt_eff_date            in  date            default hr_api.g_date,
  p_enp_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_enp_attribute1               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute2               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute3               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute4               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute5               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute6               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute7               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute8               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute9               in varchar2         default hr_api.g_varchar2,
  p_enp_attribute10              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute11              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute12              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute13              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute14              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute15              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute16              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute17              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute18              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute19              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute20              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute21              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute22              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute23              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute24              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute25              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute26              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute27              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute28              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute29              in varchar2         default hr_api.g_varchar2,
  p_enp_attribute30              in varchar2         default hr_api.g_varchar2,
  p_enrt_perd_det_ovrlp_bckdt_cd in varchar2         default hr_api.g_varchar2,
  --cwb
  p_data_freeze_date              in  date           default hr_api.g_date     ,
  p_Sal_chg_reason_cd             in  varchar2       default hr_api.g_varchar2,
  p_Approval_mode_cd              in  varchar2       default hr_api.g_varchar2,
  p_hrchy_ame_trn_cd              in  varchar2       default hr_api.g_varchar2,
  p_hrchy_rl                      in  number         default hr_api.g_number,
  p_hrchy_ame_app_id              in  number         default hr_api.g_number,
  --
  p_object_version_number         in out nocopy number
 ,p_reinstate_cd		  in varchar2	default hr_api.g_varchar2
 ,p_reinstate_ovrdn_cd		  in varchar2	default hr_api.g_varchar2
 ,p_defer_deenrol_flag            in varchar2	default hr_api.g_varchar2
  );
--
end ben_enp_upd;

/
