--------------------------------------------------------
--  DDL for Package PAY_EEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EEI_INS" AUTHID CURRENT_USER as
/* $Header: pyeeirhi.pkh 120.2 2005/08/20 09:39:31 rtahilia noship $ */
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
  (p_rec                          in out nocopy pay_eei_shd.g_rec_type
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
  (p_element_type_id                in     number
  ,p_information_type               in     varchar2
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_eei_attribute_category         in     varchar2 default null
  ,p_eei_attribute1                 in     varchar2 default null
  ,p_eei_attribute2                 in     varchar2 default null
  ,p_eei_attribute3                 in     varchar2 default null
  ,p_eei_attribute4                 in     varchar2 default null
  ,p_eei_attribute5                 in     varchar2 default null
  ,p_eei_attribute6                 in     varchar2 default null
  ,p_eei_attribute7                 in     varchar2 default null
  ,p_eei_attribute8                 in     varchar2 default null
  ,p_eei_attribute9                 in     varchar2 default null
  ,p_eei_attribute10                in     varchar2 default null
  ,p_eei_attribute11                in     varchar2 default null
  ,p_eei_attribute12                in     varchar2 default null
  ,p_eei_attribute13                in     varchar2 default null
  ,p_eei_attribute14                in     varchar2 default null
  ,p_eei_attribute15                in     varchar2 default null
  ,p_eei_attribute16                in     varchar2 default null
  ,p_eei_attribute17                in     varchar2 default null
  ,p_eei_attribute18                in     varchar2 default null
  ,p_eei_attribute19                in     varchar2 default null
  ,p_eei_attribute20                in     varchar2 default null
  ,p_eei_information_category       in     varchar2 default null
  ,p_eei_information1               in     varchar2 default null
  ,p_eei_information2               in     varchar2 default null
  ,p_eei_information3               in     varchar2 default null
  ,p_eei_information4               in     varchar2 default null
  ,p_eei_information5               in     varchar2 default null
  ,p_eei_information6               in     varchar2 default null
  ,p_eei_information7               in     varchar2 default null
  ,p_eei_information8               in     varchar2 default null
  ,p_eei_information9               in     varchar2 default null
  ,p_eei_information10              in     varchar2 default null
  ,p_eei_information11              in     varchar2 default null
  ,p_eei_information12              in     varchar2 default null
  ,p_eei_information13              in     varchar2 default null
  ,p_eei_information14              in     varchar2 default null
  ,p_eei_information15              in     varchar2 default null
  ,p_eei_information16              in     varchar2 default null
  ,p_eei_information17              in     varchar2 default null
  ,p_eei_information18              in     varchar2 default null
  ,p_eei_information19              in     varchar2 default null
  ,p_eei_information20              in     varchar2 default null
  ,p_eei_information21              in     varchar2 default null
  ,p_eei_information22              in     varchar2 default null
  ,p_eei_information23              in     varchar2 default null
  ,p_eei_information24              in     varchar2 default null
  ,p_eei_information25              in     varchar2 default null
  ,p_eei_information26              in     varchar2 default null
  ,p_eei_information27              in     varchar2 default null
  ,p_eei_information28              in     varchar2 default null
  ,p_eei_information29              in     varchar2 default null
  ,p_eei_information30              in     varchar2 default null
  ,p_element_type_extra_info_id        out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end pay_eei_ins;

 

/
