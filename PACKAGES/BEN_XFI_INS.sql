--------------------------------------------------------
--  DDL for Package BEN_XFI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XFI_INS" AUTHID CURRENT_USER as
/* $Header: bexfirhi.pkh 120.0 2005/05/28 12:33:47 appldev noship $ */

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
  p_rec        in out nocopy ben_xfi_shd.g_rec_type
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
  p_ext_file_id                  out nocopy number,
  p_name                         in varchar2         default null,
  p_xml_tag_name                 in varchar2         default null,
  p_business_group_id            in number,
  p_legislation_code             in varchar2         default null,
  p_xfi_attribute_category       in varchar2         default null,
  p_xfi_attribute1               in varchar2         default null,
  p_xfi_attribute2               in varchar2         default null,
  p_xfi_attribute3               in varchar2         default null,
  p_xfi_attribute4               in varchar2         default null,
  p_xfi_attribute5               in varchar2         default null,
  p_xfi_attribute6               in varchar2         default null,
  p_xfi_attribute7               in varchar2         default null,
  p_xfi_attribute8               in varchar2         default null,
  p_xfi_attribute9               in varchar2         default null,
  p_xfi_attribute10              in varchar2         default null,
  p_xfi_attribute11              in varchar2         default null,
  p_xfi_attribute12              in varchar2         default null,
  p_xfi_attribute13              in varchar2         default null,
  p_xfi_attribute14              in varchar2         default null,
  p_xfi_attribute15              in varchar2         default null,
  p_xfi_attribute16              in varchar2         default null,
  p_xfi_attribute17              in varchar2         default null,
  p_xfi_attribute18              in varchar2         default null,
  p_xfi_attribute19              in varchar2         default null,
  p_xfi_attribute20              in varchar2         default null,
  p_xfi_attribute21              in varchar2         default null,
  p_xfi_attribute22              in varchar2         default null,
  p_xfi_attribute23              in varchar2         default null,
  p_xfi_attribute24              in varchar2         default null,
  p_xfi_attribute25              in varchar2         default null,
  p_xfi_attribute26              in varchar2         default null,
  p_xfi_attribute27              in varchar2         default null,
  p_xfi_attribute28              in varchar2         default null,
  p_xfi_attribute29              in varchar2         default null,
  p_xfi_attribute30              in varchar2         default null,
  P_ext_rcd_in_file_id           in number           default null,
  p_ext_data_elmt_in_rcd_id1     in number           default null,
  p_ext_data_elmt_in_rcd_id2     in number           default null,
  p_last_update_date             in date             default null,
  p_creation_date                in date             default null,
  p_last_updated_by              in number           default null,
  p_last_update_login            in number           default null,
  p_created_by                   in number           default null,
  p_object_version_number        out nocopy number
  );
--
end ben_xfi_ins;

 

/