--------------------------------------------------------
--  DDL for Package PAY_PPM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPM_SHD" AUTHID CURRENT_USER as
/* $Header: pyppmrhi.pkh 120.0.12010000.2 2008/12/05 13:44:17 abanand ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  personal_payment_method_id        pay_personal_payment_methods_f.personal_payment_method_id%TYPE, -- Bug 7499474
  effective_start_date              pay_personal_payment_methods_f.effective_start_date%TYPE,
  effective_end_date                pay_personal_payment_methods_f.effective_end_date%TYPE,
  business_group_id                 pay_personal_payment_methods_f.business_group_id%TYPE,
  external_account_id               pay_personal_payment_methods_f.external_account_id%TYPE,
  assignment_id                     pay_personal_payment_methods_f.assignment_id%TYPE,
  run_type_id                       pay_personal_payment_methods_f.run_type_id%TYPE,
  org_payment_method_id             pay_personal_payment_methods_f.org_payment_method_id%TYPE,
  amount                            pay_personal_payment_methods_f.amount%TYPE,
  comment_id                        pay_personal_payment_methods_f.comment_id%TYPE,
  comments                          varchar2(2000),   -- pseudo column
  percentage                        pay_personal_payment_methods_f.percentage%TYPE,
  priority                          pay_personal_payment_methods_f.priority%TYPE,
  attribute_category                pay_personal_payment_methods_f.attribute_category%TYPE,
  attribute1                        pay_personal_payment_methods_f.attribute1%TYPE,
  attribute2                        pay_personal_payment_methods_f.attribute2%TYPE,
  attribute3                        pay_personal_payment_methods_f.attribute3%TYPE,
  attribute4                        pay_personal_payment_methods_f.attribute4%TYPE,
  attribute5                        pay_personal_payment_methods_f.attribute5%TYPE,
  attribute6                        pay_personal_payment_methods_f.attribute6%TYPE,
  attribute7                        pay_personal_payment_methods_f.attribute7%TYPE,
  attribute8                        pay_personal_payment_methods_f.attribute8%TYPE,
  attribute9                        pay_personal_payment_methods_f.attribute9%TYPE,
  attribute10                       pay_personal_payment_methods_f.attribute10%TYPE,
  attribute11                       pay_personal_payment_methods_f.attribute11%TYPE,
  attribute12                       pay_personal_payment_methods_f.attribute12%TYPE,
  attribute13                       pay_personal_payment_methods_f.attribute13%TYPE,
  attribute14                       pay_personal_payment_methods_f.attribute14%TYPE,
  attribute15                       pay_personal_payment_methods_f.attribute15%TYPE,
  attribute16                       pay_personal_payment_methods_f.attribute16%TYPE,
  attribute17                       pay_personal_payment_methods_f.attribute17%TYPE,
  attribute18                       pay_personal_payment_methods_f.attribute18%TYPE,
  attribute19                       pay_personal_payment_methods_f.attribute19%TYPE,
  attribute20                       pay_personal_payment_methods_f.attribute20%TYPE,
  object_version_number             pay_personal_payment_methods_f.object_version_number%TYPE,
  payee_type                        pay_personal_payment_methods_f.payee_type%TYPE,
  payee_id                          pay_personal_payment_methods_f.payee_id%TYPE,
  ppm_information_category          pay_personal_payment_methods_f.ppm_information_category%TYPE,
  ppm_information1                  pay_personal_payment_methods_f.ppm_information1%TYPE,
  ppm_information2                  pay_personal_payment_methods_f.ppm_information2%TYPE,
  ppm_information3                  pay_personal_payment_methods_f.ppm_information3%TYPE,
  ppm_information4                  pay_personal_payment_methods_f.ppm_information4%TYPE,
  ppm_information5                  pay_personal_payment_methods_f.ppm_information5%TYPE,
  ppm_information6                  pay_personal_payment_methods_f.ppm_information6%TYPE,
  ppm_information7                  pay_personal_payment_methods_f.ppm_information7%TYPE,
  ppm_information8                  pay_personal_payment_methods_f.ppm_information8%TYPE,
  ppm_information9                  pay_personal_payment_methods_f.ppm_information9%TYPE,
  ppm_information10                 pay_personal_payment_methods_f.ppm_information10%TYPE,
  ppm_information11                 pay_personal_payment_methods_f.ppm_information11%TYPE,
  ppm_information12                 pay_personal_payment_methods_f.ppm_information12%TYPE,
  ppm_information13                 pay_personal_payment_methods_f.ppm_information13%TYPE,
  ppm_information14                 pay_personal_payment_methods_f.ppm_information14%TYPE,
  ppm_information15                 pay_personal_payment_methods_f.ppm_information15%TYPE,
  ppm_information16                 pay_personal_payment_methods_f.ppm_information16%TYPE,
  ppm_information17                 pay_personal_payment_methods_f.ppm_information17%TYPE,
  ppm_information18                 pay_personal_payment_methods_f.ppm_information18%TYPE,
  ppm_information19                 pay_personal_payment_methods_f.ppm_information19%TYPE,
  ppm_information20                 pay_personal_payment_methods_f.ppm_information20%TYPE,
  ppm_information21                 pay_personal_payment_methods_f.ppm_information21%TYPE,
  ppm_information22                 pay_personal_payment_methods_f.ppm_information22%TYPE,
  ppm_information23                 pay_personal_payment_methods_f.ppm_information23%TYPE,
  ppm_information24                 pay_personal_payment_methods_f.ppm_information24%TYPE,
  ppm_information25                 pay_personal_payment_methods_f.ppm_information25%TYPE,
  ppm_information26                 pay_personal_payment_methods_f.ppm_information26%TYPE,
  ppm_information27                 pay_personal_payment_methods_f.ppm_information27%TYPE,
  ppm_information28                 pay_personal_payment_methods_f.ppm_information28%TYPE,
  ppm_information29                 pay_personal_payment_methods_f.ppm_information29%TYPE,
  ppm_information30                 pay_personal_payment_methods_f.ppm_information30%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Pre Conditions:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which correspond with a constraint error.
--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the current
--   row from the database for the specified primary key provided that the
--   primary key exists and is valid and does not already match the current
--   g_old_rec.
--   The function will always return a TRUE value if the g_old_rec is
--   populated with the current row. A FALSE value will be returned if all of
--   the primary key arguments are null.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec is
--   current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date		in date,
   p_personal_payment_method_id		in number,
   p_object_version_number	in number
  ) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack delete modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the delete modes
--   available where TRUE indicates that the corresponding delete mode is
--   available.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :personal_payment_method_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack delete mode of
--   ZAP. To implement this you would have to set and return a Boolean value
--   of FALSE after the call to the dt_api.find_dt_del_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap			out nocopy boolean,
	 p_delete		out nocopy boolean,
	 p_future_change	out nocopy boolean,
	 p_delete_next_change	out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack update modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the update modes
--   available where TRUE indicates that the corresponding update mode
--   is available.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :personal_payment_method_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack update mode of
--   UPDATE. To implement this you would have to set and return a Boolean
--   value of FALSE after the call to the dt_api.find_dt_upd_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction		out nocopy boolean,
	 p_update		out nocopy boolean,
	 p_update_override	out nocopy boolean,
	 p_update_change_insert	out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will update the specified datetrack row with the
--   specified new effective end date. The object version number is also
--   set to the next object version number. DateTrack modes which call
--   this procedure are: UPDATE, UPDATE_CHANGE_INSERT,
--   UPDATE_OVERRIDE, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE.
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_new_effective_end_date
--     Specifies the new effective end date which will be set for the
--     row as of the effective date.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :personal_payment_method_id).
--
-- Post Success:
--   The specified row will be updated with the new effective end date and
--   object_version_number.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process for datetrack is complicated and comprises of the
--   following processing
--   The processing steps are as follows:
--   1) The row to be updated or deleted must be locked.
--      By locking this row, the g_old_rec record data type is populated.
--   2) If a comment exists the text is selected from hr_comments.
--   3) The datetrack mode is then validated to ensure the operation is
--      valid. If the mode is valid the validation start and end dates for
--      the mode will be derived and returned. Any required locking is
--      completed when the datetrack mode is validated.
--
-- Pre Conditions:
--   When attempting to call the lck procedure the object version number,
--   primary key, effective date and datetrack mode must be specified.
--
-- In Arguments:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update or delete mode.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_personal_payment_method_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_personal_payment_method_id    in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_external_account_id           in number,
	p_assignment_id                 in number,
        p_run_type_id                   in number,
	p_org_payment_method_id         in number,
	p_amount                        in number,
	p_comment_id                    in number,
	p_comments                      in varchar2,
	p_percentage                    in number,
	p_priority                      in number,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_object_version_number         in number,
	p_payee_type                    in varchar2,
	p_payee_id                      in number,
        p_ppm_information_category      in varchar2,
        p_ppm_information1              in varchar2,
        p_ppm_information2              in varchar2,
        p_ppm_information3              in varchar2,
        p_ppm_information4              in varchar2,
        p_ppm_information5              in varchar2,
        p_ppm_information6              in varchar2,
        p_ppm_information7              in varchar2,
        p_ppm_information8              in varchar2,
        p_ppm_information9              in varchar2,
        p_ppm_information10             in varchar2,
        p_ppm_information11             in varchar2,
        p_ppm_information12             in varchar2,
        p_ppm_information13             in varchar2,
        p_ppm_information14             in varchar2,
        p_ppm_information15             in varchar2,
        p_ppm_information16             in varchar2,
        p_ppm_information17             in varchar2,
        p_ppm_information18             in varchar2,
        p_ppm_information19             in varchar2,
        p_ppm_information20             in varchar2,
        p_ppm_information21             in varchar2,
        p_ppm_information22             in varchar2,
        p_ppm_information23             in varchar2,
        p_ppm_information24             in varchar2,
        p_ppm_information25             in varchar2,
        p_ppm_information26             in varchar2,
        p_ppm_information27             in varchar2,
        p_ppm_information28             in varchar2,
        p_ppm_information29             in varchar2,
        p_ppm_information30             in varchar2
	)
	Return g_rec_type;
--
end pay_ppm_shd;

/
