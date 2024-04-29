--------------------------------------------------------
--  DDL for Package BEN_PCG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCG_INS" AUTHID CURRENT_USER as
/* $Header: bepcgrhi.pkh 120.0 2005/05/28 10:11:18 appldev noship $ */

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
  p_rec        in out nocopy ben_pcg_shd.g_rec_type
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
  p_prtt_clm_gd_or_svc_typ_id    out nocopy number,
  p_prtt_reimbmt_rqst_id         in number,
  p_gd_or_svc_typ_id             in number           default null,
  p_business_group_id            in number,
  p_pcg_attribute_category       in varchar2         default null,
  p_pcg_attribute1               in varchar2         default null,
  p_pcg_attribute2               in varchar2         default null,
  p_pcg_attribute3               in varchar2         default null,
  p_pcg_attribute4               in varchar2         default null,
  p_pcg_attribute5               in varchar2         default null,
  p_pcg_attribute6               in varchar2         default null,
  p_pcg_attribute7               in varchar2         default null,
  p_pcg_attribute8               in varchar2         default null,
  p_pcg_attribute9               in varchar2         default null,
  p_pcg_attribute10              in varchar2         default null,
  p_pcg_attribute11              in varchar2         default null,
  p_pcg_attribute12              in varchar2         default null,
  p_pcg_attribute13              in varchar2         default null,
  p_pcg_attribute14              in varchar2         default null,
  p_pcg_attribute15              in varchar2         default null,
  p_pcg_attribute16              in varchar2         default null,
  p_pcg_attribute17              in varchar2         default null,
  p_pcg_attribute18              in varchar2         default null,
  p_pcg_attribute19              in varchar2         default null,
  p_pcg_attribute20              in varchar2         default null,
  p_pcg_attribute21              in varchar2         default null,
  p_pcg_attribute22              in varchar2         default null,
  p_pcg_attribute23              in varchar2         default null,
  p_pcg_attribute24              in varchar2         default null,
  p_pcg_attribute25              in varchar2         default null,
  p_pcg_attribute26              in varchar2         default null,
  p_pcg_attribute27              in varchar2         default null,
  p_pcg_attribute28              in varchar2         default null,
  p_pcg_attribute29              in varchar2         default null,
  p_pcg_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_pl_gd_or_svc_id              in number           default null
  );
--
end ben_pcg_ins;

 

/
