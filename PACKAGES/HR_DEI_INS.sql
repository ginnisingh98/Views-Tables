--------------------------------------------------------
--  DDL for Package HR_DEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DEI_INS" AUTHID CURRENT_USER as
/* $Header: hrdeirhi.pkh 120.1.12010000.2 2010/04/07 11:45:05 tkghosh ship $ */
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
  (p_document_extra_info_id  in  number);
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
  (p_rec                      in out nocopy hr_dei_shd.g_rec_type
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
  (p_person_id                      in     number
  ,p_document_type_id               in     number
  ,p_date_from                      in     date
  ,p_date_to                        in     date  default null
  ,p_document_number                in     varchar2 default null
  ,p_issued_by                      in     varchar2 default null
  ,p_issued_at                      in     varchar2 default null
  ,p_issued_date                    in     date     default null
  ,p_issuing_authority              in     varchar2 default null
  ,p_verified_by                    in     number   default null
  ,p_verified_date                  in     date     default null
  ,p_related_object_name            in     varchar2 default null
  ,p_related_object_id_col          in     varchar2 default null
  ,p_related_object_id              in     number   default null
  ,p_dei_attribute_category         in     varchar2 default null
  ,p_dei_attribute1                 in     varchar2 default null
  ,p_dei_attribute2                 in     varchar2 default null
  ,p_dei_attribute3                 in     varchar2 default null
  ,p_dei_attribute4                 in     varchar2 default null
  ,p_dei_attribute5                 in     varchar2 default null
  ,p_dei_attribute6                 in     varchar2 default null
  ,p_dei_attribute7                 in     varchar2 default null
  ,p_dei_attribute8                 in     varchar2 default null
  ,p_dei_attribute9                 in     varchar2 default null
  ,p_dei_attribute10                in     varchar2 default null
  ,p_dei_attribute11                in     varchar2 default null
  ,p_dei_attribute12                in     varchar2 default null
  ,p_dei_attribute13                in     varchar2 default null
  ,p_dei_attribute14                in     varchar2 default null
  ,p_dei_attribute15                in     varchar2 default null
  ,p_dei_attribute16                in     varchar2 default null
  ,p_dei_attribute17                in     varchar2 default null
  ,p_dei_attribute18                in     varchar2 default null
  ,p_dei_attribute19                in     varchar2 default null
  ,p_dei_attribute20                in     varchar2 default null
  ,p_dei_attribute21                in     varchar2 default null
  ,p_dei_attribute22                in     varchar2 default null
  ,p_dei_attribute23                in     varchar2 default null
  ,p_dei_attribute24                in     varchar2 default null
  ,p_dei_attribute25                in     varchar2 default null
  ,p_dei_attribute26                in     varchar2 default null
  ,p_dei_attribute27                in     varchar2 default null
  ,p_dei_attribute28                in     varchar2 default null
  ,p_dei_attribute29                in     varchar2 default null
  ,p_dei_attribute30                in     varchar2 default null
  ,p_dei_information_category       in     varchar2 default null
  ,p_dei_information1               in     varchar2 default null
  ,p_dei_information2               in     varchar2 default null
  ,p_dei_information3               in     varchar2 default null
  ,p_dei_information4               in     varchar2 default null
  ,p_dei_information5               in     varchar2 default null
  ,p_dei_information6               in     varchar2 default null
  ,p_dei_information7               in     varchar2 default null
  ,p_dei_information8               in     varchar2 default null
  ,p_dei_information9               in     varchar2 default null
  ,p_dei_information10              in     varchar2 default null
  ,p_dei_information11              in     varchar2 default null
  ,p_dei_information12              in     varchar2 default null
  ,p_dei_information13              in     varchar2 default null
  ,p_dei_information14              in     varchar2 default null
  ,p_dei_information15              in     varchar2 default null
  ,p_dei_information16              in     varchar2 default null
  ,p_dei_information17              in     varchar2 default null
  ,p_dei_information18              in     varchar2 default null
  ,p_dei_information19              in     varchar2 default null
  ,p_dei_information20              in     varchar2 default null
  ,p_dei_information21              in     varchar2 default null
  ,p_dei_information22              in     varchar2 default null
  ,p_dei_information23              in     varchar2 default null
  ,p_dei_information24              in     varchar2 default null
  ,p_dei_information25              in     varchar2 default null
  ,p_dei_information26              in     varchar2 default null
  ,p_dei_information27              in     varchar2 default null
  ,p_dei_information28              in     varchar2 default null
  ,p_dei_information29              in     varchar2 default null
  ,p_dei_information30              in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_document_extra_info_id            out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_dei_ins;

/
