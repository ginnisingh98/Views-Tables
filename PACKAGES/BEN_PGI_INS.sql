--------------------------------------------------------
--  DDL for Package BEN_PGI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGI_INS" AUTHID CURRENT_USER as
/* $Header: bepgirhi.pkh 120.0 2005/05/28 10:46:19 appldev noship $ */
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
  p_rec        in out nocopy ben_pgi_shd.g_rec_type,
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
--   2) After the conversion has taken pgmace, the corresponding record ins
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
  p_pgm_extra_info_id            out nocopy number,
  p_information_type             in varchar2,
  p_pgm_id                       in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_pgi_attribute_category       in varchar2         default null,
  p_pgi_attribute1               in varchar2         default null,
  p_pgi_attribute2               in varchar2         default null,
  p_pgi_attribute3               in varchar2         default null,
  p_pgi_attribute4               in varchar2         default null,
  p_pgi_attribute5               in varchar2         default null,
  p_pgi_attribute6               in varchar2         default null,
  p_pgi_attribute7               in varchar2         default null,
  p_pgi_attribute8               in varchar2         default null,
  p_pgi_attribute9               in varchar2         default null,
  p_pgi_attribute10              in varchar2         default null,
  p_pgi_attribute11              in varchar2         default null,
  p_pgi_attribute12              in varchar2         default null,
  p_pgi_attribute13              in varchar2         default null,
  p_pgi_attribute14              in varchar2         default null,
  p_pgi_attribute15              in varchar2         default null,
  p_pgi_attribute16              in varchar2         default null,
  p_pgi_attribute17              in varchar2         default null,
  p_pgi_attribute18              in varchar2         default null,
  p_pgi_attribute19              in varchar2         default null,
  p_pgi_attribute20              in varchar2         default null,
  p_pgi_information_category     in varchar2         default null,
  p_pgi_information1             in varchar2         default null,
  p_pgi_information2             in varchar2         default null,
  p_pgi_information3             in varchar2         default null,
  p_pgi_information4             in varchar2         default null,
  p_pgi_information5             in varchar2         default null,
  p_pgi_information6             in varchar2         default null,
  p_pgi_information7             in varchar2         default null,
  p_pgi_information8             in varchar2         default null,
  p_pgi_information9             in varchar2         default null,
  p_pgi_information10            in varchar2         default null,
  p_pgi_information11            in varchar2         default null,
  p_pgi_information12            in varchar2         default null,
  p_pgi_information13            in varchar2         default null,
  p_pgi_information14            in varchar2         default null,
  p_pgi_information15            in varchar2         default null,
  p_pgi_information16            in varchar2         default null,
  p_pgi_information17            in varchar2         default null,
  p_pgi_information18            in varchar2         default null,
  p_pgi_information19            in varchar2         default null,
  p_pgi_information20            in varchar2         default null,
  p_pgi_information21            in varchar2         default null,
  p_pgi_information22            in varchar2         default null,
  p_pgi_information23            in varchar2         default null,
  p_pgi_information24            in varchar2         default null,
  p_pgi_information25            in varchar2         default null,
  p_pgi_information26            in varchar2         default null,
  p_pgi_information27            in varchar2         default null,
  p_pgi_information28            in varchar2         default null,
  p_pgi_information29            in varchar2         default null,
  p_pgi_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  );
--
end ben_pgi_ins;

 

/