--------------------------------------------------------
--  DDL for Package BEN_CLP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLP_UPD" AUTHID CURRENT_USER as
/* $Header: beclprhi.pkh 120.0 2005/05/28 01:05:05 appldev noship $ */
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
  p_rec			in out nocopy 	ben_clp_shd.g_rec_type,
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
  p_clpse_lf_evt_id              in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number           default hr_api.g_number,
  p_seq                          in number           default hr_api.g_number,
  p_ler1_id                      in number           default hr_api.g_number,
  p_bool1_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler2_id                      in number           default hr_api.g_number,
  p_bool2_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler3_id                      in number           default hr_api.g_number,
  p_bool3_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler4_id                      in number           default hr_api.g_number,
  p_bool4_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler5_id                      in number           default hr_api.g_number,
  p_bool5_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler6_id                      in number           default hr_api.g_number,
  p_bool6_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler7_id                      in number           default hr_api.g_number,
  p_bool7_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler8_id                      in number           default hr_api.g_number,
  p_bool8_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler9_id                      in number           default hr_api.g_number,
  p_bool9_cd                     in varchar2         default hr_api.g_varchar2,
  p_ler10_id                     in number           default hr_api.g_number,
  p_eval_cd                      in varchar2         default hr_api.g_varchar2,
  p_eval_rl                      in number           default hr_api.g_number,
  p_tlrnc_dys_num                in number           default hr_api.g_number,
  p_eval_ler_id                  in number           default hr_api.g_number,
  p_eval_ler_det_cd              in varchar2         default hr_api.g_varchar2,
  p_eval_ler_det_rl              in number           default hr_api.g_number,
  p_clp_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_clp_attribute1               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute2               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute3               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute4               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute5               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute6               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute7               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute8               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute9               in varchar2         default hr_api.g_varchar2,
  p_clp_attribute10              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute11              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute12              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute13              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute14              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute15              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute16              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute17              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute18              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute19              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute20              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute21              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute22              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute23              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute24              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute25              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute26              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute27              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute28              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute29              in varchar2         default hr_api.g_varchar2,
  p_clp_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_clp_upd;

 

/
