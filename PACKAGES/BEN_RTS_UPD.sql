--------------------------------------------------------
--  DDL for Package BEN_RTS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RTS_UPD" AUTHID CURRENT_USER as
/* $Header: bertsrhi.pkh 120.1 2006/01/09 14:36 maagrawa noship $ */
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
  (p_rec                          in out nocopy ben_rts_shd.g_rec_type
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
--   Though the designated primary key is person_rate_id, update and delete
--   operations are performed based on group_per_in_ler_id, pl_id and oipl_id
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_group_per_in_ler_id          in     number
  ,p_pl_id                        in     number
  ,p_oipl_id                      in     number
  ,p_object_version_number        in out nocopy number
  ,p_group_pl_id                  in     number    default hr_api.g_number
  ,p_group_oipl_id                in     number    default hr_api.g_number
  ,p_lf_evt_ocrd_dt               in     date      default hr_api.g_date
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_elig_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_ws_val                       in     number    default hr_api.g_number
  ,p_ws_mn_val                    in     number    default hr_api.g_number
  ,p_ws_mx_val                    in     number    default hr_api.g_number
  ,p_ws_incr_val                  in     number    default hr_api.g_number
  ,p_elig_sal_val                 in     number    default hr_api.g_number
  ,p_stat_sal_val                 in     number    default hr_api.g_number
  ,p_oth_comp_val                 in     number    default hr_api.g_number
  ,p_tot_comp_val                 in     number    default hr_api.g_number
  ,p_misc1_val                    in     number    default hr_api.g_number
  ,p_misc2_val                    in     number    default hr_api.g_number
  ,p_misc3_val                    in     number    default hr_api.g_number
  ,p_rec_val                      in     number    default hr_api.g_number
  ,p_rec_mn_val                   in     number    default hr_api.g_number
  ,p_rec_mx_val                   in     number    default hr_api.g_number
  ,p_rec_incr_val                 in     number    default hr_api.g_number
  ,p_ws_val_last_upd_date         in     date      default hr_api.g_date
  ,p_ws_val_last_upd_by           in     number    default hr_api.g_number
  ,p_pay_proposal_id              in     number    default hr_api.g_number
  ,p_element_entry_value_id       in     number    default hr_api.g_number
  ,p_inelig_rsn_cd                in     varchar2  default hr_api.g_varchar2
  ,p_elig_ovrid_dt                in     date      default hr_api.g_date
  ,p_elig_ovrid_person_id         in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_val           in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_val             in     number    default hr_api.g_number
  ,p_copy_rsrv_val                in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_mn_val        in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_mx_val        in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_incr_val      in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_mn_val          in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_mx_val          in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_incr_val        in     number    default hr_api.g_number
  ,p_copy_rsrv_mn_val             in     number    default hr_api.g_number
  ,p_copy_rsrv_mx_val             in     number    default hr_api.g_number
  ,p_copy_rsrv_incr_val           in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_iss_val       in     number    default hr_api.g_number
  ,p_copy_ws_bdgt_iss_val         in     number    default hr_api.g_number
  ,p_copy_dist_bdgt_iss_date      in     date      default hr_api.g_date
  ,p_copy_ws_bdgt_iss_date        in     date      default hr_api.g_date
  ,p_comp_posting_date            in     date      default hr_api.g_date
  ,p_ws_rt_start_date             in     date      default hr_api.g_date
  ,p_currency                     in     varchar2  default hr_api.g_varchar2
  );
--
end ben_rts_upd;

 

/
