--------------------------------------------------------
--  DDL for Package PER_QUA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUA_UPD" AUTHID CURRENT_USER as
/* $Header: pequarhi.pkh 120.0.12010000.1 2008/07/28 05:32:25 appldev ship $ */
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
  p_rec            in out nocopy per_qua_shd .g_rec_type,
  p_effective_date in     date,
  p_validate       in     boolean default false
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
  p_qualification_id             in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_person_id                    in number           default hr_api.g_number,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_grade_attained               in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_awarded_date                 in date             default hr_api.g_date,
  p_fee                          in number           default hr_api.g_number,
  p_fee_currency                 in varchar2         default hr_api.g_varchar2,
  p_training_completed_amount    in number           default hr_api.g_number,
  p_reimbursement_arrangements   in varchar2         default hr_api.g_varchar2,
  p_training_completed_units     in varchar2         default hr_api.g_varchar2,
  p_total_training_amount        in number           default hr_api.g_number,
  p_start_date                   in date             default hr_api.g_date,
  p_end_date                     in date             default hr_api.g_date,
  p_license_number               in varchar2         default hr_api.g_varchar2,
  p_expiry_date                  in date             default hr_api.g_date,
  p_license_restrictions         in varchar2         default hr_api.g_varchar2,
  p_projected_completion_date    in date             default hr_api.g_date,
  p_awarding_body                in varchar2         default hr_api.g_varchar2,
  p_tuition_method               in varchar2         default hr_api.g_varchar2,
  p_group_ranking                in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_qualification_type_id        in number           default hr_api.g_number,
  p_attendance_id                in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
	p_qua_information_category            in varchar2 default hr_api.g_varchar2,
	p_qua_information1                    in varchar2 default hr_api.g_varchar2,
	p_qua_information2                    in varchar2 default hr_api.g_varchar2,
	p_qua_information3                    in varchar2 default hr_api.g_varchar2,
	p_qua_information4                    in varchar2 default hr_api.g_varchar2,
	p_qua_information5                    in varchar2 default hr_api.g_varchar2,
	p_qua_information6                    in varchar2 default hr_api.g_varchar2,
	p_qua_information7                    in varchar2 default hr_api.g_varchar2,
	p_qua_information8                    in varchar2 default hr_api.g_varchar2,
	p_qua_information9                    in varchar2 default hr_api.g_varchar2,
	p_qua_information10                   in varchar2 default hr_api.g_varchar2,
	p_qua_information11                   in varchar2 default hr_api.g_varchar2,
	p_qua_information12                   in varchar2 default hr_api.g_varchar2,
	p_qua_information13                   in varchar2 default hr_api.g_varchar2,
	p_qua_information14                   in varchar2 default hr_api.g_varchar2,
	p_qua_information15                   in varchar2 default hr_api.g_varchar2,
	p_qua_information16                   in varchar2 default hr_api.g_varchar2,
	p_qua_information17                   in varchar2 default hr_api.g_varchar2,
	p_qua_information18                   in varchar2 default hr_api.g_varchar2,
	p_qua_information19                   in varchar2 default hr_api.g_varchar2,
	p_qua_information20                   in varchar2 default hr_api.g_varchar2,
  p_effective_date               in date,
  p_validate                     in boolean      default false,
  p_professional_body_name       in varchar2     default hr_api.g_varchar2,
  p_membership_number            in varchar2     default hr_api.g_varchar2,
  p_membership_category          in varchar2     default hr_api.g_varchar2,
  p_subscription_payment_method  in varchar2     default hr_api.g_varchar2,
  p_party_id                     in number       default hr_api.g_number
  );
--
end per_qua_upd;

/
