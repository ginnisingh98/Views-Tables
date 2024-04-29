--------------------------------------------------------
--  DDL for Package PQH_REI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_REI_INS" AUTHID CURRENT_USER as
/* $Header: pqreirhi.pkh 120.0 2005/05/29 02:27:10 appldev noship $ */
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
  (p_role_extra_info_id  in  number);
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
--   1) If the p_validate parameter has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--   p_validate
--     Determines if the process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     process and is rollbacked at the end of the process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed.If the p_validate parameter has been set to true
--   then all the work will be rolled back.
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
  ( p_rec          in out nocopy pqh_rei_shd.g_rec_type
   ,p_validate     in     boolean default false
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
--   p_validate
--     Determines if the process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
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
  (p_role_id                   in     number
  ,p_information_type          in     varchar2
  ,p_request_id                in     number   default null
  ,p_program_application_id    in     number   default null
  ,p_program_id                in     number   default null
  ,p_program_update_date       in     date     default null
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_attribute21               in     varchar2 default null
  ,p_attribute22               in     varchar2 default null
  ,p_attribute23               in     varchar2 default null
  ,p_attribute24               in     varchar2 default null
  ,p_attribute25               in     varchar2 default null
  ,p_attribute26               in     varchar2 default null
  ,p_attribute27               in     varchar2 default null
  ,p_attribute28               in     varchar2 default null
  ,p_attribute29               in     varchar2 default null
  ,p_attribute30               in     varchar2 default null
  ,p_information_category      in     varchar2 default null
  ,p_information1              in     varchar2 default null
  ,p_information2              in     varchar2 default null
  ,p_information3              in     varchar2 default null
  ,p_information4              in     varchar2 default null
  ,p_information5              in     varchar2 default null
  ,p_information6              in     varchar2 default null
  ,p_information7              in     varchar2 default null
  ,p_information8              in     varchar2 default null
  ,p_information9              in     varchar2 default null
  ,p_information10             in     varchar2 default null
  ,p_information11             in     varchar2 default null
  ,p_information12             in     varchar2 default null
  ,p_information13             in     varchar2 default null
  ,p_information14             in     varchar2 default null
  ,p_information15             in     varchar2 default null
  ,p_information16             in     varchar2 default null
  ,p_information17             in     varchar2 default null
  ,p_information18             in     varchar2 default null
  ,p_information19             in     varchar2 default null
  ,p_information20             in     varchar2 default null
  ,p_information21             in     varchar2 default null
  ,p_information22             in     varchar2 default null
  ,p_information23             in     varchar2 default null
  ,p_information24             in     varchar2 default null
  ,p_information25             in     varchar2 default null
  ,p_information26             in     varchar2 default null
  ,p_information27             in     varchar2 default null
  ,p_information28             in     varchar2 default null
  ,p_information29             in     varchar2 default null
  ,p_information30             in     varchar2 default null
  ,p_role_extra_info_id        out nocopy number
  ,p_object_version_number     out nocopy number
  ,p_validate                  in boolean   default false
  );
--
end pqh_rei_ins;

 

/
