--------------------------------------------------------
--  DDL for Package PER_BPD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPD_INS" AUTHID CURRENT_USER as
/* $Header: pebpdrhi.pkh 120.0 2005/05/31 06:19:02 appldev noship $ */
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
  p_effective_date   in  date,
  p_rec        in out nocopy per_bpd_shd.g_rec_type
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
  p_effective_date   in  date,
  p_payment_detail_id            out nocopy number,
  p_processed_assignment_id      in number,
  p_personal_payment_method_id   in number,
  p_business_group_id            in number,
  p_check_number                 in number           default null,
  p_payment_date                   in date             default null,
  p_amount                       in number           default null,
  p_check_type                   in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_bpd_attribute_category           in varchar2         default null,
  p_bpd_attribute1                  in varchar2         default null,
  p_bpd_attribute2                  in varchar2         default null,
  p_bpd_attribute3                  in varchar2         default null,
  p_bpd_attribute4                  in varchar2         default null,
  p_bpd_attribute5                  in varchar2         default null,
  p_bpd_attribute6                  in varchar2         default null,
  p_bpd_attribute7                  in varchar2         default null,
  p_bpd_attribute8                  in varchar2         default null,
  p_bpd_attribute9                  in varchar2         default null,
  p_bpd_attribute10                 in varchar2         default null,
  p_bpd_attribute11                 in varchar2         default null,
  p_bpd_attribute12                 in varchar2         default null,
  p_bpd_attribute13                 in varchar2         default null,
  p_bpd_attribute14                 in varchar2         default null,
  p_bpd_attribute15                 in varchar2         default null,
  p_bpd_attribute16                 in varchar2         default null,
  p_bpd_attribute17                 in varchar2         default null,
  p_bpd_attribute18                 in varchar2         default null,
  p_bpd_attribute19                 in varchar2         default null,
  p_bpd_attribute20                 in varchar2         default null,
  p_bpd_attribute21                 in varchar2         default null,
  p_bpd_attribute22                 in varchar2         default null,
  p_bpd_attribute23                 in varchar2         default null,
  p_bpd_attribute24                 in varchar2         default null,
  p_bpd_attribute25                 in varchar2         default null,
  p_bpd_attribute26                 in varchar2         default null,
  p_bpd_attribute27                 in varchar2         default null,
  p_bpd_attribute28                 in varchar2         default null,
  p_bpd_attribute29                 in varchar2         default null,
  p_bpd_attribute30                 in varchar2         default null

 );
--
end per_bpd_ins;

 

/
