--------------------------------------------------------
--  DDL for Package PAY_PPM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPM_INS" AUTHID CURRENT_USER as
/* $Header: pyppmrhi.pkh 120.0.12010000.2 2008/12/05 13:44:17 abanand ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Pre Conditions:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Arguments:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
(p_effective_date	 in  date
,p_datetrack_mode	 in  varchar2
,p_rec	 		 in  pay_ppm_shd.g_rec_type
,p_validation_start_date out nocopy date
,p_validation_end_date	 out nocopy date
);
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy pay_ppm_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) We must lock parent rows (if any exist).
--   3) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   5) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   6) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   7) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--   The following attributes in p_rec are mandatory:
--   personal_payment_method_id, assignment_id, business_group_id,
--   org_payment_method_id, effective_start_date, effective_end_date
--
-- In Arguments:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--   The primary key and object version number details for the inserted
--   personal payment method record will be returned in p_rec
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--   A failure will occur if any of the following conditions are found:
--   1) All of the mandatory arguments have not been set
--   2) A row does not exist in per_assignments_f for the value in
--      p_rec.assignment_id as of the current effective date
--   3) The value in p_rec.org_payment_method_id is not valid for the
--      assignments related payroll id, as of p_effective_start_date
--   4) The value in p_rec.org_payment_method_id is not valid for the
--      related payment type
--   5) The balance type related to the value in
--      p_rec.personal_payment_method_id  is
--      non-remunerative and the value in p_rec.amount is not null
--   6) The balance type related to the value in
--      p_rec.personal_payment_method_id  is
--      non-remunerative and the value in p_rec.percentage is not 100
--   7) The value in p_rec.percentage is not null and the value in
--      p_rec.amount is not null
--   8) The value in p_rec.percentage is null and the value in
--      p_rec.amount is null
--   9) The value in p_rec.amount is less than 0
--  10) The value in p_rec.percentage is not between 0 and 100
--  11) The related payment type is magnetic tape and the value in
--      p_rec.external_account_id is null
--  12) The value in p_rec.external_account_id is not null and it does
--      not exist in PAY_EXTERNAL_ACCOUNTS
--  13) The value in p_rec.priority is null
--  14) The balance type related to the value in
--      p_rec.personal_payment_method_id is Remunerative and
--      the value in p_rec.priority is not an integer between 1 and 99
--  15) The balance type related to the value in
--      p_rec.personal_payment_method_id is Non_Remunerative and
--      the value in p_rec.priority is not 1
--  16) The balance type related to the value in
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
Procedure ins
  (
  p_rec		   in out nocopy pay_ppm_shd.g_rec_type,
  p_effective_date in     date,
  p_validate	   in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
--   p_validate
--     Determines if the business process is to be validated. Setting this
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
--   rolled back. Refer to the ins record interface for details of possible
--   failures
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
  p_personal_payment_method_id   out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_external_account_id          in number           default null,
  p_assignment_id                in number,
  p_run_type_id                  in number           default null,
  p_org_payment_method_id        in number,
  p_amount                       in number           default null,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default null,
  p_percentage                   in number           default null,
  p_priority                     in number           default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_payee_type                   in varchar2         default null,
  p_payee_id                     in number           default null,
  p_effective_date		 in date,
  p_validate			 in boolean          default false,
  p_ppm_information_category     in varchar2         default null,
  p_ppm_information1             in varchar2         default null,
  p_ppm_information2             in varchar2         default null,
  p_ppm_information3             in varchar2         default null,
  p_ppm_information4             in varchar2         default null,
  p_ppm_information5             in varchar2         default null,
  p_ppm_information6             in varchar2         default null,
  p_ppm_information7             in varchar2         default null,
  p_ppm_information8             in varchar2         default null,
  p_ppm_information9             in varchar2         default null,
  p_ppm_information10            in varchar2         default null,
  p_ppm_information11            in varchar2         default null,
  p_ppm_information12            in varchar2         default null,
  p_ppm_information13            in varchar2         default null,
  p_ppm_information14            in varchar2         default null,
  p_ppm_information15            in varchar2         default null,
  p_ppm_information16            in varchar2         default null,
  p_ppm_information17            in varchar2         default null,
  p_ppm_information18            in varchar2         default null,
  p_ppm_information19            in varchar2         default null,
  p_ppm_information20            in varchar2         default null,
  p_ppm_information21            in varchar2         default null,
  p_ppm_information22            in varchar2         default null,
  p_ppm_information23            in varchar2         default null,
  p_ppm_information24            in varchar2         default null,
  p_ppm_information25            in varchar2         default null,
  p_ppm_information26            in varchar2         default null,
  p_ppm_information27            in varchar2         default null,
  p_ppm_information28            in varchar2         default null,
  p_ppm_information29            in varchar2         default null,
  p_ppm_information30            in varchar2         default null
  );
--
end pay_ppm_ins;

/
