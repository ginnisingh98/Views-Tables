--------------------------------------------------------
--  DDL for Package BEN_WYP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WYP_INS" AUTHID CURRENT_USER as
/* $Header: bewyprhi.pkh 120.0 2005/05/28 12:21:53 appldev noship $ */

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
  p_rec        in out nocopy ben_wyp_shd.g_rec_type
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
  p_wthn_yr_perd_id              out nocopy number,
  p_strt_day                     in number           default null,
  p_end_day                      in number           default null,
  p_strt_mo                      in number           default null,
  p_end_mo                       in number           default null,
  p_tm_uom                       in varchar2         default null,
  p_yr_perd_id                   in number           default null,
  p_business_group_id            in number           default null,
  p_wyp_attribute_category       in varchar2         default null,
  p_wyp_attribute1               in varchar2         default null,
  p_wyp_attribute2               in varchar2         default null,
  p_wyp_attribute3               in varchar2         default null,
  p_wyp_attribute4               in varchar2         default null,
  p_wyp_attribute5               in varchar2         default null,
  p_wyp_attribute6               in varchar2         default null,
  p_wyp_attribute7               in varchar2         default null,
  p_wyp_attribute8               in varchar2         default null,
  p_wyp_attribute9               in varchar2         default null,
  p_wyp_attribute10              in varchar2         default null,
  p_wyp_attribute11              in varchar2         default null,
  p_wyp_attribute12              in varchar2         default null,
  p_wyp_attribute13              in varchar2         default null,
  p_wyp_attribute14              in varchar2         default null,
  p_wyp_attribute15              in varchar2         default null,
  p_wyp_attribute16              in varchar2         default null,
  p_wyp_attribute17              in varchar2         default null,
  p_wyp_attribute18              in varchar2         default null,
  p_wyp_attribute19              in varchar2         default null,
  p_wyp_attribute20              in varchar2         default null,
  p_wyp_attribute21              in varchar2         default null,
  p_wyp_attribute22              in varchar2         default null,
  p_wyp_attribute23              in varchar2         default null,
  p_wyp_attribute24              in varchar2         default null,
  p_wyp_attribute25              in varchar2         default null,
  p_wyp_attribute26              in varchar2         default null,
  p_wyp_attribute27              in varchar2         default null,
  p_wyp_attribute28              in varchar2         default null,
  p_wyp_attribute29              in varchar2         default null,
  p_wyp_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  );
--
end ben_wyp_ins;

 

/
