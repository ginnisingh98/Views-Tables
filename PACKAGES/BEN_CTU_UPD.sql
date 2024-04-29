--------------------------------------------------------
--  DDL for Package BEN_CTU_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTU_UPD" AUTHID CURRENT_USER as
/* $Header: becturhi.pkh 120.0 2005/05/28 01:28:25 appldev noship $ */
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
  p_rec			in out nocopy 	ben_ctu_shd.g_rec_type,
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
  p_cm_typ_usg_id                in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_all_r_any_cd                 in varchar2         default hr_api.g_varchar2,
  p_cm_usg_rl                    in number           default hr_api.g_number,
  p_descr_text                   in varchar2         default hr_api.g_varchar2,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_pl_typ_id                    in number           default hr_api.g_number,
  p_enrt_perd_id                 in number           default hr_api.g_number,
  p_actn_typ_id                  in number           default hr_api.g_number,
  p_cm_typ_id                    in number           default hr_api.g_number,
  p_ler_id                       in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_ctu_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute1               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute2               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute3               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute4               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute5               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute6               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute7               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute8               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute9               in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute10              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute11              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute12              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute13              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute14              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute15              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute16              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute17              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute18              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute19              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute20              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute21              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute22              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute23              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute24              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute25              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute26              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute27              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute28              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute29              in varchar2         default hr_api.g_varchar2,
  p_ctu_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
end ben_ctu_upd;

 

/