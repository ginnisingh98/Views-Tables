--------------------------------------------------------
--  DDL for Package PAY_PPM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPM_UPD" AUTHID CURRENT_USER as
/* $Header: pyppmrhi.pkh 120.0.12010000.2 2008/12/05 13:44:17 abanand ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd business process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   3) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   4) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   5) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   6) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   7) The update_dml process will physical perform the update dml into the
--      specified entity.
--   8) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   9) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--   p_rec
--     Contains the attributes of the personal payment method record
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode. If
--   the p_validate argument has been set to true then all the work will be
--   rolled back.
--   p_rec.object_version_number will be set to the new object_version_number
--   for the personal payment method
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--   A failure will occur if any of the following conditions are found:
--   1) All of the mandatory arguments have not been set
--   2) An attempt is made to update one of the following attributes:
--      personal_payment_method_id, assignment_id, business_group_id or
--      org_payment_method_id
--   3) The balance type related to the value in
--      p_rec.personal_payment_method_id  is
--      non-remunerative and the value in p_rec.amount is not null
--   4) The balance type related to the value in
--      p_rec.personal_payment_method_id  is
--      non-remunerative and the value in p_rec.percentage is not 100
--   5) The value in p_rec.percentage is not null and the value in
--      p_rec.amount is not null
--   6) The value in p_rec.percentage is null and the value in
--      p_rec.amount is null
--   7) The value in p_rec.amount is less than 0
--   8) The value in p_rec.percentage is not between 0 and 100
--   9) The related payment type is magnetic tape and the value in
--      p_rec.external_account_id is null
--  10) The value in p_rec.external_account_id is not null and it does
--      not exist in PAY_EXTERNAL_ACCOUNTS
--  11) The value in p_rec.priority is null
--  12) The balance type related to the value in
--      p_rec.personal_payment_method_id is Remunerative and
--      the value in p_rec.priority is not an integer between 1 and 99
--  13) The balance type related to the value in
--      p_rec.personal_payment_method_id is Non_Remunerative and
--      the value in p_rec.priority is not 1
--  14) The balance type related to the value in
--      p_rec.personal_payment_method_id is Remunerative and
--      the value in p_rec.priority is not unique between
--      VALIDATION_START_DATE and VALIDATION_END_DATE
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
  p_rec			in out nocopy 	pay_ppm_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2,
  p_validate		in 	boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   business process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs procedure.
--   2) After the conversion has taken place, the corresponding record upd
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--   p_validate
--     Determines if the business process is to be validated. Setting this
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
--   rolled back. Refer to the upd record interface for details of possible
--   failures.
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
  p_personal_payment_method_id   in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_external_account_id          in number           default hr_api.g_number,
  p_amount                       in number           default hr_api.g_number,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_percentage                   in number           default hr_api.g_number,
  p_priority                     in number           default hr_api.g_number,
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
  p_object_version_number        in out nocopy number,
  p_payee_type                   in varchar2         default hr_api.g_varchar2,
  p_payee_id                     in number           default hr_api.g_number,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2,
  p_validate			 in boolean          default false,
  p_ppm_information_category     in varchar2         default hr_api.g_varchar2,
  p_ppm_information1             in varchar2         default hr_api.g_varchar2,
  p_ppm_information2             in varchar2         default hr_api.g_varchar2,
  p_ppm_information3             in varchar2         default hr_api.g_varchar2,
  p_ppm_information4             in varchar2         default hr_api.g_varchar2,
  p_ppm_information5             in varchar2         default hr_api.g_varchar2,
  p_ppm_information6             in varchar2         default hr_api.g_varchar2,
  p_ppm_information7             in varchar2         default hr_api.g_varchar2,
  p_ppm_information8             in varchar2         default hr_api.g_varchar2,
  p_ppm_information9             in varchar2         default hr_api.g_varchar2,
  p_ppm_information10            in varchar2         default hr_api.g_varchar2,
  p_ppm_information11            in varchar2         default hr_api.g_varchar2,
  p_ppm_information12            in varchar2         default hr_api.g_varchar2,
  p_ppm_information13            in varchar2         default hr_api.g_varchar2,
  p_ppm_information14            in varchar2         default hr_api.g_varchar2,
  p_ppm_information15            in varchar2         default hr_api.g_varchar2,
  p_ppm_information16            in varchar2         default hr_api.g_varchar2,
  p_ppm_information17            in varchar2         default hr_api.g_varchar2,
  p_ppm_information18            in varchar2         default hr_api.g_varchar2,
  p_ppm_information19            in varchar2         default hr_api.g_varchar2,
  p_ppm_information20            in varchar2         default hr_api.g_varchar2,
  p_ppm_information21            in varchar2         default hr_api.g_varchar2,
  p_ppm_information22            in varchar2         default hr_api.g_varchar2,
  p_ppm_information23            in varchar2         default hr_api.g_varchar2,
  p_ppm_information24            in varchar2         default hr_api.g_varchar2,
  p_ppm_information25            in varchar2         default hr_api.g_varchar2,
  p_ppm_information26            in varchar2         default hr_api.g_varchar2,
  p_ppm_information27            in varchar2         default hr_api.g_varchar2,
  p_ppm_information28            in varchar2         default hr_api.g_varchar2,
  p_ppm_information29            in varchar2         default hr_api.g_varchar2,
  p_ppm_information30            in varchar2         default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this procedure. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure convert_defs(p_rec in out nocopy pay_ppm_shd.g_rec_type);
end pay_ppm_upd;

/
