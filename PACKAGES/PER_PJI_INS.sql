--------------------------------------------------------
--  DDL for Package PER_PJI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PJI_INS" AUTHID CURRENT_USER as
/* $Header: pepjirhi.pkh 120.0 2005/05/31 14:22:49 appldev noship $ */
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
  (p_previous_job_extra_info_id  in  number);
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
  (p_rec                          in out nocopy per_pji_shd.g_rec_type
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
  (p_previous_job_id                in     number
  ,p_information_type               in     varchar2
  ,p_pji_attribute_category         in     varchar2 default null
  ,p_pji_attribute1                 in     varchar2 default null
  ,p_pji_attribute2                 in     varchar2 default null
  ,p_pji_attribute3                 in     varchar2 default null
  ,p_pji_attribute4                 in     varchar2 default null
  ,p_pji_attribute5                 in     varchar2 default null
  ,p_pji_attribute6                 in     varchar2 default null
  ,p_pji_attribute7                 in     varchar2 default null
  ,p_pji_attribute8                 in     varchar2 default null
  ,p_pji_attribute9                 in     varchar2 default null
  ,p_pji_attribute10                in     varchar2 default null
  ,p_pji_attribute11                in     varchar2 default null
  ,p_pji_attribute12                in     varchar2 default null
  ,p_pji_attribute13                in     varchar2 default null
  ,p_pji_attribute14                in     varchar2 default null
  ,p_pji_attribute15                in     varchar2 default null
  ,p_pji_attribute16                in     varchar2 default null
  ,p_pji_attribute17                in     varchar2 default null
  ,p_pji_attribute18                in     varchar2 default null
  ,p_pji_attribute19                in     varchar2 default null
  ,p_pji_attribute20                in     varchar2 default null
  ,p_pji_attribute21                in     varchar2 default null
  ,p_pji_attribute22                in     varchar2 default null
  ,p_pji_attribute23                in     varchar2 default null
  ,p_pji_attribute24                in     varchar2 default null
  ,p_pji_attribute25                in     varchar2 default null
  ,p_pji_attribute26                in     varchar2 default null
  ,p_pji_attribute27                in     varchar2 default null
  ,p_pji_attribute28                in     varchar2 default null
  ,p_pji_attribute29                in     varchar2 default null
  ,p_pji_attribute30                in     varchar2 default null
  ,p_pji_information_category       in     varchar2 default null
  ,p_pji_information1               in     varchar2 default null
  ,p_pji_information2               in     varchar2 default null
  ,p_pji_information3               in     varchar2 default null
  ,p_pji_information4               in     varchar2 default null
  ,p_pji_information5               in     varchar2 default null
  ,p_pji_information6               in     varchar2 default null
  ,p_pji_information7               in     varchar2 default null
  ,p_pji_information8               in     varchar2 default null
  ,p_pji_information9               in     varchar2 default null
  ,p_pji_information10              in     varchar2 default null
  ,p_pji_information11              in     varchar2 default null
  ,p_pji_information12              in     varchar2 default null
  ,p_pji_information13              in     varchar2 default null
  ,p_pji_information14              in     varchar2 default null
  ,p_pji_information15              in     varchar2 default null
  ,p_pji_information16              in     varchar2 default null
  ,p_pji_information17              in     varchar2 default null
  ,p_pji_information18              in     varchar2 default null
  ,p_pji_information19              in     varchar2 default null
  ,p_pji_information20              in     varchar2 default null
  ,p_pji_information21              in     varchar2 default null
  ,p_pji_information22              in     varchar2 default null
  ,p_pji_information23              in     varchar2 default null
  ,p_pji_information24              in     varchar2 default null
  ,p_pji_information25              in     varchar2 default null
  ,p_pji_information26              in     varchar2 default null
  ,p_pji_information27              in     varchar2 default null
  ,p_pji_information28              in     varchar2 default null
  ,p_pji_information29              in     varchar2 default null
  ,p_pji_information30              in     varchar2 default null
  ,p_previous_job_extra_info_id        out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end per_pji_ins;

 

/
