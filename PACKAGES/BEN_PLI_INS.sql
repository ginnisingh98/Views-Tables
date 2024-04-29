--------------------------------------------------------
--  DDL for Package BEN_PLI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLI_INS" AUTHID CURRENT_USER as
/* $Header: beplirhi.pkh 120.0.12010000.1 2008/07/29 12:50:44 appldev ship $ */
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
--   2) The controlling validation process insert_validate is then executed
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
-- Pre Conditions:
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
--   without being committed. If the p_validate parameter has been set to true
--   then all the work will be rolled back.
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
  p_rec        in out nocopy ben_pli_shd.g_rec_type,
  p_validate   in     boolean default false
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
-- Pre Conditions:
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
  p_pl_extra_info_id            out nocopy number,
  p_information_type             in varchar2,
  p_pl_id                       in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_pli_attribute_category       in varchar2         default null,
  p_pli_attribute1               in varchar2         default null,
  p_pli_attribute2               in varchar2         default null,
  p_pli_attribute3               in varchar2         default null,
  p_pli_attribute4               in varchar2         default null,
  p_pli_attribute5               in varchar2         default null,
  p_pli_attribute6               in varchar2         default null,
  p_pli_attribute7               in varchar2         default null,
  p_pli_attribute8               in varchar2         default null,
  p_pli_attribute9               in varchar2         default null,
  p_pli_attribute10              in varchar2         default null,
  p_pli_attribute11              in varchar2         default null,
  p_pli_attribute12              in varchar2         default null,
  p_pli_attribute13              in varchar2         default null,
  p_pli_attribute14              in varchar2         default null,
  p_pli_attribute15              in varchar2         default null,
  p_pli_attribute16              in varchar2         default null,
  p_pli_attribute17              in varchar2         default null,
  p_pli_attribute18              in varchar2         default null,
  p_pli_attribute19              in varchar2         default null,
  p_pli_attribute20              in varchar2         default null,
  p_pli_information_category     in varchar2         default null,
  p_pli_information1             in varchar2         default null,
  p_pli_information2             in varchar2         default null,
  p_pli_information3             in varchar2         default null,
  p_pli_information4             in varchar2         default null,
  p_pli_information5             in varchar2         default null,
  p_pli_information6             in varchar2         default null,
  p_pli_information7             in varchar2         default null,
  p_pli_information8             in varchar2         default null,
  p_pli_information9             in varchar2         default null,
  p_pli_information10            in varchar2         default null,
  p_pli_information11            in varchar2         default null,
  p_pli_information12            in varchar2         default null,
  p_pli_information13            in varchar2         default null,
  p_pli_information14            in varchar2         default null,
  p_pli_information15            in varchar2         default null,
  p_pli_information16            in varchar2         default null,
  p_pli_information17            in varchar2         default null,
  p_pli_information18            in varchar2         default null,
  p_pli_information19            in varchar2         default null,
  p_pli_information20            in varchar2         default null,
  p_pli_information21            in varchar2         default null,
  p_pli_information22            in varchar2         default null,
  p_pli_information23            in varchar2         default null,
  p_pli_information24            in varchar2         default null,
  p_pli_information25            in varchar2         default null,
  p_pli_information26            in varchar2         default null,
  p_pli_information27            in varchar2         default null,
  p_pli_information28            in varchar2         default null,
  p_pli_information29            in varchar2         default null,
  p_pli_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  );
--
end ben_pli_ins;

/
