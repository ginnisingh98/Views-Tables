--------------------------------------------------------
--  DDL for Package BEN_CPG_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPG_UPD" AUTHID CURRENT_USER as
/* $Header: becpgrhi.pkh 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
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
--   If an error has occurred, an error message will be raised.
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
  (p_rec                          in out nocopy ben_cpg_shd.g_rec_type
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
--   If an error has occurred, an error message will be raised.
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
  (p_group_per_in_ler_id          in     number
  ,p_group_pl_id                  in     number
  ,p_group_oipl_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_lf_evt_ocrd_dt               in     date      default hr_api.g_date
  ,p_bdgt_pop_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_due_dt                       in     date      default hr_api.g_date
  ,p_access_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_approval_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_approval_date                in     date      default hr_api.g_date
  ,p_approval_comments            in     varchar2  default hr_api.g_varchar2
  ,p_submit_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_submit_date                  in     date      default hr_api.g_date
  ,p_submit_comments              in     varchar2  default hr_api.g_varchar2
  ,p_dist_bdgt_val                in     number    default hr_api.g_number
  ,p_ws_bdgt_val                  in     number    default hr_api.g_number
  ,p_rsrv_val                     in     number    default hr_api.g_number
  ,p_dist_bdgt_mn_val             in     number    default hr_api.g_number
  ,p_dist_bdgt_mx_val             in     number    default hr_api.g_number
  ,p_dist_bdgt_incr_val           in     number    default hr_api.g_number
  ,p_ws_bdgt_mn_val               in     number    default hr_api.g_number
  ,p_ws_bdgt_mx_val               in     number    default hr_api.g_number
  ,p_ws_bdgt_incr_val             in     number    default hr_api.g_number
  ,p_rsrv_mn_val                  in     number    default hr_api.g_number
  ,p_rsrv_mx_val                  in     number    default hr_api.g_number
  ,p_rsrv_incr_val                in     number    default hr_api.g_number
  ,p_dist_bdgt_iss_val            in     number    default hr_api.g_number
  ,p_ws_bdgt_iss_val              in     number    default hr_api.g_number
  ,p_dist_bdgt_iss_date           in     date      default hr_api.g_date
  ,p_ws_bdgt_iss_date             in     date      default hr_api.g_date
  ,p_ws_bdgt_val_last_upd_date    in     date      default hr_api.g_date
  ,p_dist_bdgt_val_last_upd_date  in     date      default hr_api.g_date
  ,p_rsrv_val_last_upd_date       in     date      default hr_api.g_date
  ,p_ws_bdgt_val_last_upd_by      in     number    default hr_api.g_number
  ,p_dist_bdgt_val_last_upd_by    in     number    default hr_api.g_number
  ,p_rsrv_val_last_upd_by         in     number    default hr_api.g_number
  );
--
end ben_cpg_upd;

 

/
