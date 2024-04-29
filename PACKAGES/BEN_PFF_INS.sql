--------------------------------------------------------
--  DDL for Package BEN_PFF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PFF_INS" AUTHID CURRENT_USER as
/* $Header: bepffrhi.pkh 120.0 2005/05/28 10:42:36 appldev noship $ */

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
  (
  p_effective_date               in date,
  p_rec        in out nocopy ben_pff_shd.g_rec_type
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
  p_effective_date               in date,
  p_pct_fl_tm_fctr_id            out nocopy number,
  p_name                         in varchar2,
  p_business_group_id            in number,
  p_mx_pct_val                   in number           default null,
  p_mn_pct_val                   in number           default null,
  p_no_mn_pct_val_flag           in varchar2         default null,
  p_no_mx_pct_val_flag           in varchar2         default null,
  p_use_prmry_asnt_only_flag     in varchar2         default null,
  p_use_sum_of_all_asnts_flag    in varchar2         default null,
  p_rndg_cd                      in varchar2         default null,
  p_rndg_rl                      in number           default null,
  p_pff_attribute_category       in varchar2         default null,
  p_pff_attribute1               in varchar2         default null,
  p_pff_attribute2               in varchar2         default null,
  p_pff_attribute3               in varchar2         default null,
  p_pff_attribute4               in varchar2         default null,
  p_pff_attribute5               in varchar2         default null,
  p_pff_attribute6               in varchar2         default null,
  p_pff_attribute7               in varchar2         default null,
  p_pff_attribute8               in varchar2         default null,
  p_pff_attribute9               in varchar2         default null,
  p_pff_attribute10              in varchar2         default null,
  p_pff_attribute11              in varchar2         default null,
  p_pff_attribute12              in varchar2         default null,
  p_pff_attribute13              in varchar2         default null,
  p_pff_attribute14              in varchar2         default null,
  p_pff_attribute15              in varchar2         default null,
  p_pff_attribute16              in varchar2         default null,
  p_pff_attribute17              in varchar2         default null,
  p_pff_attribute18              in varchar2         default null,
  p_pff_attribute19              in varchar2         default null,
  p_pff_attribute20              in varchar2         default null,
  p_pff_attribute21              in varchar2         default null,
  p_pff_attribute22              in varchar2         default null,
  p_pff_attribute23              in varchar2         default null,
  p_pff_attribute24              in varchar2         default null,
  p_pff_attribute25              in varchar2         default null,
  p_pff_attribute26              in varchar2         default null,
  p_pff_attribute27              in varchar2         default null,
  p_pff_attribute28              in varchar2         default null,
  p_pff_attribute29              in varchar2         default null,
  p_pff_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  );
--
end ben_pff_ins;

 

/
