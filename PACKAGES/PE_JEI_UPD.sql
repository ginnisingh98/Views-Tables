--------------------------------------------------------
--  DDL for Package PE_JEI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_JEI_UPD" AUTHID CURRENT_USER as
/* $Header: pejeirhi.pkh 120.0 2005/05/31 10:37:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate parameter has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate parameter has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main parameters to the business process have to be in the record
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
--     the exception because, by raising the exception with the
--     process, we can exit successfully without having any of the 'OUT'
--     parameters being set.
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
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
Procedure upd
  (
  p_rec        in out nocopy pe_jei_shd.g_rec_type,
  p_validate   in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
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
--   A fully validated row will be updated for the specified entity
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
Procedure upd
  (
  p_job_extra_info_id            in number,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_jei_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_jei_attribute1               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute2               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute3               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute4               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute5               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute6               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute7               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute8               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute9               in varchar2         default hr_api.g_varchar2,
  p_jei_attribute10              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute11              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute12              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute13              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute14              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute15              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute16              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute17              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute18              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute19              in varchar2         default hr_api.g_varchar2,
  p_jei_attribute20              in varchar2         default hr_api.g_varchar2,
  p_jei_information_category     in varchar2         default hr_api.g_varchar2,
  p_jei_information1             in varchar2         default hr_api.g_varchar2,
  p_jei_information2             in varchar2         default hr_api.g_varchar2,
  p_jei_information3             in varchar2         default hr_api.g_varchar2,
  p_jei_information4             in varchar2         default hr_api.g_varchar2,
  p_jei_information5             in varchar2         default hr_api.g_varchar2,
  p_jei_information6             in varchar2         default hr_api.g_varchar2,
  p_jei_information7             in varchar2         default hr_api.g_varchar2,
  p_jei_information8             in varchar2         default hr_api.g_varchar2,
  p_jei_information9             in varchar2         default hr_api.g_varchar2,
  p_jei_information10            in varchar2         default hr_api.g_varchar2,
  p_jei_information11            in varchar2         default hr_api.g_varchar2,
  p_jei_information12            in varchar2         default hr_api.g_varchar2,
  p_jei_information13            in varchar2         default hr_api.g_varchar2,
  p_jei_information14            in varchar2         default hr_api.g_varchar2,
  p_jei_information15            in varchar2         default hr_api.g_varchar2,
  p_jei_information16            in varchar2         default hr_api.g_varchar2,
  p_jei_information17            in varchar2         default hr_api.g_varchar2,
  p_jei_information18            in varchar2         default hr_api.g_varchar2,
  p_jei_information19            in varchar2         default hr_api.g_varchar2,
  p_jei_information20            in varchar2         default hr_api.g_varchar2,
  p_jei_information21            in varchar2         default hr_api.g_varchar2,
  p_jei_information22            in varchar2         default hr_api.g_varchar2,
  p_jei_information23            in varchar2         default hr_api.g_varchar2,
  p_jei_information24            in varchar2         default hr_api.g_varchar2,
  p_jei_information25            in varchar2         default hr_api.g_varchar2,
  p_jei_information26            in varchar2         default hr_api.g_varchar2,
  p_jei_information27            in varchar2         default hr_api.g_varchar2,
  p_jei_information28            in varchar2         default hr_api.g_varchar2,
  p_jei_information29            in varchar2         default hr_api.g_varchar2,
  p_jei_information30            in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean      default false
  );
--
end pe_jei_upd;

 

/
