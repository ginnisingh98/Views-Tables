--------------------------------------------------------
--  DDL for Package PQP_VAI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VAI_INS" AUTHID CURRENT_USER as
/* $Header: pqvairhi.pkh 120.0.12010000.2 2008/08/08 07:19:40 ubhat ship $ */
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
  (p_veh_alloc_extra_info_id  in  number);
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
  (p_rec                      in out nocopy pqp_vai_shd.g_rec_type
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
  (p_vehicle_allocation_id          in     number
  ,p_information_type               in     varchar2
  ,p_vaei_attribute_category        in     varchar2 default null
  ,p_vaei_attribute1                in     varchar2 default null
  ,p_vaei_attribute2                in     varchar2 default null
  ,p_vaei_attribute3                in     varchar2 default null
  ,p_vaei_attribute4                in     varchar2 default null
  ,p_vaei_attribute5                in     varchar2 default null
  ,p_vaei_attribute6                in     varchar2 default null
  ,p_vaei_attribute7                in     varchar2 default null
  ,p_vaei_attribute8                in     varchar2 default null
  ,p_vaei_attribute9                in     varchar2 default null
  ,p_vaei_attribute10               in     varchar2 default null
  ,p_vaei_attribute11               in     varchar2 default null
  ,p_vaei_attribute12               in     varchar2 default null
  ,p_vaei_attribute13               in     varchar2 default null
  ,p_vaei_attribute14               in     varchar2 default null
  ,p_vaei_attribute15               in     varchar2 default null
  ,p_vaei_attribute16               in     varchar2 default null
  ,p_vaei_attribute17               in     varchar2 default null
  ,p_vaei_attribute18               in     varchar2 default null
  ,p_vaei_attribute19               in     varchar2 default null
  ,p_vaei_attribute20               in     varchar2 default null
  ,p_vaei_information_category      in     varchar2 default null
  ,p_vaei_information1              in     varchar2 default null
  ,p_vaei_information2              in     varchar2 default null
  ,p_vaei_information3              in     varchar2 default null
  ,p_vaei_information4              in     varchar2 default null
  ,p_vaei_information5              in     varchar2 default null
  ,p_vaei_information6              in     varchar2 default null
  ,p_vaei_information7              in     varchar2 default null
  ,p_vaei_information8              in     varchar2 default null
  ,p_vaei_information9              in     varchar2 default null
  ,p_vaei_information10             in     varchar2 default null
  ,p_vaei_information11             in     varchar2 default null
  ,p_vaei_information12             in     varchar2 default null
  ,p_vaei_information13             in     varchar2 default null
  ,p_vaei_information14             in     varchar2 default null
  ,p_vaei_information15             in     varchar2 default null
  ,p_vaei_information16             in     varchar2 default null
  ,p_vaei_information17             in     varchar2 default null
  ,p_vaei_information18             in     varchar2 default null
  ,p_vaei_information19             in     varchar2 default null
  ,p_vaei_information20             in     varchar2 default null
  ,p_vaei_information21             in     varchar2 default null
  ,p_vaei_information22             in     varchar2 default null
  ,p_vaei_information23             in     varchar2 default null
  ,p_vaei_information24             in     varchar2 default null
  ,p_vaei_information25             in     varchar2 default null
  ,p_vaei_information26             in     varchar2 default null
  ,p_vaei_information27             in     varchar2 default null
  ,p_vaei_information28             in     varchar2 default null
  ,p_vaei_information29             in     varchar2 default null
  ,p_vaei_information30             in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_veh_alloc_extra_info_id           out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end pqp_vai_ins;

/
