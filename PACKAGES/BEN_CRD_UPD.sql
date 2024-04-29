--------------------------------------------------------
--  DDL for Package BEN_CRD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRD_UPD" AUTHID CURRENT_USER as
/* $Header: becrdrhi.pkh 120.0 2005/05/28 01:21:21 appldev noship $ */
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
  p_rec        in out nocopy ben_crd_shd.g_rec_type
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
  p_crt_ordr_cvrd_per_id         in number,
  p_crt_ordr_id                  in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_crd_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_crd_attribute1               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute2               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute3               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute4               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute5               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute6               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute7               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute8               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute9               in varchar2         default hr_api.g_varchar2,
  p_crd_attribute10              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute11              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute12              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute13              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute14              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute15              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute16              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute17              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute18              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute19              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute20              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute21              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute22              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute23              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute24              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute25              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute26              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute27              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute28              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute29              in varchar2         default hr_api.g_varchar2,
  p_crd_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  );
--
end ben_crd_upd;

 

/