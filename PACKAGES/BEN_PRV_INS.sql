--------------------------------------------------------
--  DDL for Package BEN_PRV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRV_INS" AUTHID CURRENT_USER as
/* $Header: beprvrhi.pkh 120.0.12000000.1 2007/01/19 22:14:47 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  ( p_rec        in out nocopy ben_prv_shd.g_rec_type , p_effective_date in date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_prtt_rt_val_id               out nocopy number,
  p_enrt_rt_id		         in number	     default null,
  p_rt_strt_dt                   in date,
  p_rt_end_dt                    in date,
  p_rt_typ_cd                    in varchar2         default null,
  p_tx_typ_cd                    in varchar2         default null,
  p_ordr_num			 in number           default null,
  p_acty_typ_cd                  in varchar2         default null,
  p_mlt_cd                       in varchar2         default null,
  p_acty_ref_perd_cd             in varchar2         default null,
  p_rt_val                       in number           default null,
  p_ann_rt_val                   in number           default null,
  p_cmcd_rt_val                  in number           default null,
  p_cmcd_ref_perd_cd             in varchar2         default null,
  p_bnft_rt_typ_cd               in varchar2         default null,
  p_dsply_on_enrt_flag           in varchar2,
  p_rt_ovridn_flag               in varchar2,
  p_rt_ovridn_thru_dt            in date             default null,
  p_elctns_made_dt               in date             default null,
  p_prtt_rt_val_stat_cd          in varchar2         default null,
  p_prtt_enrt_rslt_id            in number,
  p_cvg_amt_calc_mthd_id         in number           default null,
  p_actl_prem_id                 in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_element_entry_value_id       in number           default null,
  p_per_in_ler_id                in number           default null,
  p_ended_per_in_ler_id          in number           default null,
  p_acty_base_rt_id              in number           default null,
  p_prtt_reimbmt_rqst_id         in number           default null,
  p_prtt_rmt_aprvd_fr_pymt_id    in number           default null,
  p_pp_in_yr_used_num            in number           default null,
  p_business_group_id            in number,
  p_prv_attribute_category       in varchar2         default null,
  p_prv_attribute1               in varchar2         default null,
  p_prv_attribute2               in varchar2         default null,
  p_prv_attribute3               in varchar2         default null,
  p_prv_attribute4               in varchar2         default null,
  p_prv_attribute5               in varchar2         default null,
  p_prv_attribute6               in varchar2         default null,
  p_prv_attribute7               in varchar2         default null,
  p_prv_attribute8               in varchar2         default null,
  p_prv_attribute9               in varchar2         default null,
  p_prv_attribute10              in varchar2         default null,
  p_prv_attribute11              in varchar2         default null,
  p_prv_attribute12              in varchar2         default null,
  p_prv_attribute13              in varchar2         default null,
  p_prv_attribute14              in varchar2         default null,
  p_prv_attribute15              in varchar2         default null,
  p_prv_attribute16              in varchar2         default null,
  p_prv_attribute17              in varchar2         default null,
  p_prv_attribute18              in varchar2         default null,
  p_prv_attribute19              in varchar2         default null,
  p_prv_attribute20              in varchar2         default null,
  p_prv_attribute21              in varchar2         default null,
  p_prv_attribute22              in varchar2         default null,
  p_prv_attribute23              in varchar2         default null,
  p_prv_attribute24              in varchar2         default null,
  p_prv_attribute25              in varchar2         default null,
  p_prv_attribute26              in varchar2         default null,
  p_prv_attribute27              in varchar2         default null,
  p_prv_attribute28              in varchar2         default null,
  p_prv_attribute29              in varchar2         default null,
  p_prv_attribute30              in varchar2         default null,
  p_pk_id_table_name               in  varchar2  default null,
  p_pk_id                          in  number    default null,
  p_object_version_number        out nocopy number                      ,
  p_effective_date               in  date
  );
--
end ben_prv_ins;

 

/