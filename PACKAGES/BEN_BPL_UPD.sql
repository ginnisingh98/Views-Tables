--------------------------------------------------------
--  DDL for Package BEN_BPL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPL_UPD" AUTHID CURRENT_USER as
/* $Header: bebplrhi.pkh 120.0.12010000.1 2008/07/29 10:58:50 appldev ship $ */
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
  p_rec			in out nocopy 	ben_bpl_shd.g_rec_type,
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
  p_bnft_prvdd_ldgr_id           in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_prtt_ro_of_unusd_amt_flag    in varchar2         default hr_api.g_varchar2,
  p_frftd_val                    in number           default hr_api.g_number,
  p_prvdd_val                    in number           default hr_api.g_number,
  p_used_val                     in number           default hr_api.g_number,
  p_bnft_prvdr_pool_id           in number           default hr_api.g_number,
  p_acty_base_rt_id              in number           default hr_api.g_number,
  p_per_in_ler_id              in number           default hr_api.g_number,
  p_prtt_enrt_rslt_id            in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_bpl_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute1               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute2               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute3               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute4               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute5               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute6               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute7               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute8               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute9               in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute10              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute11              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute12              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute13              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute14              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute15              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute16              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute17              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute18              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute19              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute20              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute21              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute22              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute23              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute24              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute25              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute26              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute27              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute28              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute29              in varchar2         default hr_api.g_varchar2,
  p_bpl_attribute30              in varchar2         default hr_api.g_varchar2,
  p_cash_recd_val                in number           default hr_api.g_number,
  p_rld_up_val                   in number           default hr_api.g_number,
  p_effective_date	         in date,
  p_datetrack_mode               in varchar2,
  p_acty_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_cmcd_frftd_val               in   number           default hr_api.g_number,
  p_cmcd_prvdd_val               in   number           default hr_api.g_number,
  p_cmcd_rld_up_val              in   number           default hr_api.g_number,
  p_cmcd_used_val                in   number           default hr_api.g_number,
  p_cmcd_cash_recd_val           in   number           default hr_api.g_number,
  p_cmcd_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_ann_frftd_val                in   number           default hr_api.g_number,
  p_ann_prvdd_val                in   number           default hr_api.g_number,
  p_ann_rld_up_val               in   number           default hr_api.g_number,
  p_ann_used_val                 in   number           default hr_api.g_number,
  p_ann_cash_recd_val            in   number           default hr_api.g_number,
  p_object_version_number        in out nocopy number
  );
--
end ben_bpl_upd;

/
