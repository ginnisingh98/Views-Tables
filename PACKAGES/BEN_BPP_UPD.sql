--------------------------------------------------------
--  DDL for Package BEN_BPP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPP_UPD" AUTHID CURRENT_USER as
/* $Header: bebpprhi.pkh 120.0 2005/05/28 00:48:43 appldev noship $ */
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
  p_rec			in out nocopy 	ben_bpp_shd.g_rec_type,
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
  p_bnft_prvdr_pool_id           in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_pgm_pool_flag                in varchar2         default hr_api.g_varchar2,
  p_excs_alwys_fftd_flag         in varchar2         default hr_api.g_varchar2,
  p_use_for_pgm_pool_flag        in varchar2         default hr_api.g_varchar2,
  p_pct_rndg_cd                  in varchar2         default hr_api.g_varchar2,
  p_pct_rndg_rl                  in number           default hr_api.g_number,
  p_val_rndg_cd                  in varchar2         default hr_api.g_varchar2,
  p_val_rndg_rl                  in number           default hr_api.g_number,
  p_dflt_excs_trtmt_cd           in varchar2         default hr_api.g_varchar2,
  p_dflt_excs_trtmt_rl           in number           default hr_api.g_number,
  p_rlovr_rstrcn_cd              in varchar2         default hr_api.g_varchar2,
  p_no_mn_dstrbl_pct_flag        in varchar2         default hr_api.g_varchar2,
  p_no_mn_dstrbl_val_flag        in varchar2         default hr_api.g_varchar2,
  p_no_mx_dstrbl_pct_flag        in varchar2         default hr_api.g_varchar2,
  p_no_mx_dstrbl_val_flag        in varchar2         default hr_api.g_varchar2,
  p_auto_alct_excs_flag          in varchar2         default hr_api.g_varchar2,
  p_alws_ngtv_crs_flag           in  varchar2        default hr_api.g_varchar2,
  p_uses_net_crs_mthd_flag       in  varchar2        default hr_api.g_varchar2,
  p_mx_dfcit_pct_pool_crs_num    in  number          default hr_api.g_number,
  p_mx_dfcit_pct_comp_num        in  number          default hr_api.g_number,
  p_comp_lvl_fctr_id             in  number          default hr_api.g_number,
  p_mn_dstrbl_pct_num            in number           default hr_api.g_number,
  p_mn_dstrbl_val                in number           default hr_api.g_number,
  p_mx_dstrbl_pct_num            in number           default hr_api.g_number,
  p_mx_dstrbl_val                in number           default hr_api.g_number,
  p_excs_trtmt_cd                in varchar2         default hr_api.g_varchar2,
  p_ptip_id                      in number           default hr_api.g_number,
  p_plip_id                      in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_oiplip_id                    in number           default hr_api.g_number,
  p_cmbn_plip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_opt_id             in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_bpp_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute1               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute2               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute3               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute4               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute5               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute6               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute7               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute8               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute9               in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute10              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute11              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute12              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute13              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute14              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute15              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute16              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute17              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute18              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute19              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute20              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute21              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute22              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute23              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute24              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute25              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute26              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute27              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute28              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute29              in varchar2         default hr_api.g_varchar2,
  p_bpp_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_bpp_upd;

 

/
