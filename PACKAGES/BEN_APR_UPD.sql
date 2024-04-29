--------------------------------------------------------
--  DDL for Package BEN_APR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APR_UPD" AUTHID CURRENT_USER as
/* $Header: beaprrhi.pkh 120.0 2005/05/28 00:27:01 appldev noship $ */
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
  p_rec			in out nocopy 	ben_apr_shd.g_rec_type,
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
  p_actl_prem_id                 in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_uom                          in varchar2         default hr_api.g_varchar2,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_val                          in number           default hr_api.g_number,
  p_mlt_cd                       in varchar2         default hr_api.g_varchar2,
  p_prdct_cd                     in varchar2         default hr_api.g_varchar2,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_val_calc_rl                  in number           default hr_api.g_number,
  p_prem_asnmt_cd                 in varchar2       default hr_api.g_varchar2,
  p_prem_asnmt_lvl_cd             in varchar2       default hr_api.g_varchar2,
  p_actl_prem_typ_cd              in varchar2       default hr_api.g_varchar2,
  p_prem_pyr_cd                   in varchar2       default hr_api.g_varchar2,
  p_cr_lkbk_val                   in number         default hr_api.g_number,
  p_cr_lkbk_uom                   in varchar2       default hr_api.g_varchar2,
  p_cr_lkbk_crnt_py_only_flag     in varchar2,
  p_prsptv_r_rtsptv_cd            in varchar2      default hr_api.g_varchar2,
  p_upr_lmt_val                   in number         default hr_api.g_number,
  p_upr_lmt_calc_rl               in number         default hr_api.g_number,
  p_lwr_lmt_val                   in number         default hr_api.g_number,
  p_lwr_lmt_calc_rl               in number         default hr_api.g_number,
  p_cost_allocation_keyflex_id    in number         default hr_api.g_number,
  p_organization_id               in number         default hr_api.g_number,
  p_oipl_id                       in number         default hr_api.g_number,
  p_pl_id                         in number         default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_prtl_mo_det_mthd_cd           in varchar2        default hr_api.g_varchar2,
  p_prtl_mo_det_mthd_rl           in number          default hr_api.g_number,
  p_wsh_rl_dy_mo_num              in number          default hr_api.g_number,
  p_vrbl_rt_add_on_calc_rl        in number          default hr_api.g_number,
  p_apr_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_apr_attribute1               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute2               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute3               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute4               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute5               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute6               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute7               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute8               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute9               in varchar2         default hr_api.g_varchar2,
  p_apr_attribute10              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute11              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute12              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute13              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute14              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute15              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute16              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute17              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute18              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute19              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute20              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute21              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute22              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute23              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute24              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute25              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute26              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute27              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute28              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute29              in varchar2         default hr_api.g_varchar2,
  p_apr_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_apr_upd;

 

/
