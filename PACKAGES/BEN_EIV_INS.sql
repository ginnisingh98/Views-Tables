--------------------------------------------------------
--  DDL for Package BEN_EIV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EIV_INS" AUTHID CURRENT_USER as
/* $Header: beeivrhi.pkh 120.0 2005/05/28 02:16:44 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_extra_input_value_id  in  number);
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
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_eiv_shd.g_rec_type
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
Procedure ins
  (p_effective_date                 in     date
  ,p_acty_base_rt_id                in     number
  ,p_input_value_id                 in     number
  ,p_return_var_name                in     varchar2
  ,p_business_group_id              in     number
  ,p_input_text                     in     varchar2 default null
  ,p_upd_when_ele_ended_cd          in     varchar2 default null
  ,p_eiv_attribute_category         in     varchar2 default null
  ,p_eiv_attribute1                 in     varchar2 default null
  ,p_eiv_attribute2                 in     varchar2 default null
  ,p_eiv_attribute3                 in     varchar2 default null
  ,p_eiv_attribute4                 in     varchar2 default null
  ,p_eiv_attribute5                 in     varchar2 default null
  ,p_eiv_attribute6                 in     varchar2 default null
  ,p_eiv_attribute7                 in     varchar2 default null
  ,p_eiv_attribute8                 in     varchar2 default null
  ,p_eiv_attribute9                 in     varchar2 default null
  ,p_eiv_attribute10                in     varchar2 default null
  ,p_eiv_attribute11                in     varchar2 default null
  ,p_eiv_attribute12                in     varchar2 default null
  ,p_eiv_attribute13                in     varchar2 default null
  ,p_eiv_attribute14                in     varchar2 default null
  ,p_eiv_attribute15                in     varchar2 default null
  ,p_eiv_attribute16                in     varchar2 default null
  ,p_eiv_attribute17                in     varchar2 default null
  ,p_eiv_attribute18                in     varchar2 default null
  ,p_eiv_attribute19                in     varchar2 default null
  ,p_eiv_attribute20                in     varchar2 default null
  ,p_eiv_attribute21                in     varchar2 default null
  ,p_eiv_attribute22                in     varchar2 default null
  ,p_eiv_attribute23                in     varchar2 default null
  ,p_eiv_attribute24                in     varchar2 default null
  ,p_eiv_attribute25                in     varchar2 default null
  ,p_eiv_attribute26                in     varchar2 default null
  ,p_eiv_attribute27                in     varchar2 default null
  ,p_eiv_attribute28                in     varchar2 default null
  ,p_eiv_attribute29                in     varchar2 default null
  ,p_eiv_attribute30                in     varchar2 default null
  ,p_extra_input_value_id              out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end ben_eiv_ins;

 

/