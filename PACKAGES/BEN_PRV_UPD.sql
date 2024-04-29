--------------------------------------------------------
--  DDL for Package BEN_PRV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRV_UPD" AUTHID CURRENT_USER as
/* $Header: beprvrhi.pkh 120.0.12000000.1 2007/01/19 22:14:47 appldev noship $ */
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
  (  p_rec        in out nocopy ben_prv_shd.g_rec_type ,
     p_effective_date in date
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
  p_prtt_rt_val_id               in number,
  p_enrt_rt_id		     	 in number	     default hr_api.g_number,
  p_rt_strt_dt                   in date             default hr_api.g_date,
  p_rt_end_dt                    in date             default hr_api.g_date,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_tx_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_ordr_num			 in number           default hr_api.g_number,
  p_acty_typ_cd                  in varchar2         default hr_api.g_varchar2,
  p_mlt_cd                       in varchar2         default hr_api.g_varchar2,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_rt_val                       in number           default hr_api.g_number,
  p_ann_rt_val                   in number           default hr_api.g_number,
  p_cmcd_rt_val                  in number           default hr_api.g_number,
  p_cmcd_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_dsply_on_enrt_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_ovridn_flag               in varchar2         default hr_api.g_varchar2,
  p_rt_ovridn_thru_dt            in date             default hr_api.g_date,
  p_elctns_made_dt               in date             default hr_api.g_date,
  p_prtt_rt_val_stat_cd          in varchar2         default hr_api.g_varchar2,
  p_prtt_enrt_rslt_id            in number           default hr_api.g_number,
  p_cvg_amt_calc_mthd_id         in number           default hr_api.g_number,
  p_actl_prem_id                 in number           default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_element_entry_value_id       in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_ended_per_in_ler_id          in number           default hr_api.g_number,
  p_acty_base_rt_id              in number           default hr_api.g_number,
  p_prtt_reimbmt_rqst_id         in number           default hr_api.g_number,
  p_prtt_rmt_aprvd_fr_pymt_id    in number           default hr_api.g_number,
  p_pp_in_yr_used_num            in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_prv_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_prv_attribute1               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute2               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute3               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute4               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute5               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute6               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute7               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute8               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute9               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute10              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute11              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute12              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute13              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute14              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute15              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute16              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute17              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute18              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute19              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute20              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute21              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute22              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute23              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute24              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute25              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute26              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute27              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute28              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute29              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute30              in varchar2         default hr_api.g_varchar2,
  p_pk_id_table_name               in  varchar2  default hr_api.g_varchar2,
  p_pk_id                          in  number    default hr_api.g_number,
  p_object_version_number        in out nocopy number                                ,
  p_effective_date               in date
  );
--
end ben_prv_upd;

 

/
