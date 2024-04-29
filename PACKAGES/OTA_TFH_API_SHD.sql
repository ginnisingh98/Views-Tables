--------------------------------------------------------
--  DDL for Package OTA_TFH_API_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFH_API_SHD" AUTHID CURRENT_USER as
/* $Header: ottfh01t.pkh 120.0 2005/05/29 07:40:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  finance_header_id                 number(9),
  superceding_header_id             number(9),
  authorizer_person_id              ota_finance_headers.authorizer_person_id%TYPE,
  organization_id                   number(9),
  administrator                     number,
  cancelled_flag                    varchar2(30),
  currency_code                     varchar2(30),
  date_raised                       date,
  object_version_number             number(9),
  payment_status_flag               varchar2(30),
  transfer_status                   varchar2(30),
  type                              varchar2(30),
  receivable_type                   varchar2(30),
  comments                          varchar2(2000),
  external_reference                varchar2(30),
  invoice_address                   varchar2(2000),
  invoice_contact                   varchar2(240),
  payment_method                    varchar2(30),
  pym_attribute1                    varchar2(150),
  pym_attribute10                   varchar2(150),
  pym_attribute11                   varchar2(150),
  pym_attribute12                   varchar2(150),
  pym_attribute13                   varchar2(150),
  pym_attribute14                   varchar2(150),
  pym_attribute15                   varchar2(150),
  pym_attribute16                   varchar2(150),
  pym_attribute17                   varchar2(150),
  pym_attribute18                   varchar2(150),
  pym_attribute19                   varchar2(150),
  pym_attribute2                    varchar2(150),
  pym_attribute20                   varchar2(150),
  pym_attribute3                    varchar2(150),
  pym_attribute4                    varchar2(150),
  pym_attribute5                    varchar2(150),
  pym_attribute6                    varchar2(150),
  pym_attribute7                    varchar2(150),
  pym_attribute8                    varchar2(150),
  pym_attribute9                    varchar2(150),
  pym_information_category          varchar2(30),
  transfer_date                     date,
  transfer_message                  varchar2(240),
  vendor_id                         number(15),
  contact_id                        number(15),
  address_id                        number,
  customer_id                       number(15),
  tfh_information_category          varchar2(30),
  tfh_information1                  varchar2(150),
  tfh_information2                  varchar2(150),
  tfh_information3                  varchar2(150),
  tfh_information4                  varchar2(150),
  tfh_information5                  varchar2(150),
  tfh_information6                  varchar2(150),
  tfh_information7                  varchar2(150),
  tfh_information8                  varchar2(150),
  tfh_information9                  varchar2(150),
  tfh_information10                 varchar2(150),
  tfh_information11                 varchar2(150),
  tfh_information12                 varchar2(150),
  tfh_information13                 varchar2(150),
  tfh_information14                 varchar2(150),
  tfh_information15                 varchar2(150),
  tfh_information16                 varchar2(150),
  tfh_information17                 varchar2(150),
  tfh_information18                 varchar2(150),
  tfh_information19                 varchar2(150),
  tfh_information20                 varchar2(150),
  paying_cost_center                varchar2(800),
  receiving_cost_center             varchar2(800),
  transfer_from_set_of_book_id      number(15),
  transfer_to_set_of_book_id        number(15),
  from_segment1                     varchar2(25),
  from_segment2                 varchar2(25),
  from_segment3                 varchar2(25),
  from_segment4                 varchar2(25),
  from_segment5                 varchar2(25),
  from_segment6                 varchar2(25),
  from_segment7                 varchar2(25),
  from_segment8                 varchar2(25),
  from_segment9                 varchar2(25),
  from_segment10                varchar2(25),
  from_segment11                 varchar2(25),
  from_segment12                 varchar2(25),
  from_segment13                 varchar2(25),
  from_segment14                 varchar2(25),
  from_segment15                 varchar2(25),
  from_segment16                 varchar2(25),
  from_segment17                 varchar2(25),
  from_segment18                 varchar2(25),
  from_segment19                 varchar2(25),
  from_segment20                varchar2(25),
  from_segment21                 varchar2(25),
  from_segment22                 varchar2(25),
  from_segment23                 varchar2(25),
  from_segment24                 varchar2(25),
  from_segment25                 varchar2(25),
  from_segment26                 varchar2(25),
  from_segment27                 varchar2(25),
  from_segment28                 varchar2(25),
  from_segment29                 varchar2(25),
  from_segment30                varchar2(25),
  to_segment1                 varchar2(25),
  to_segment2                 varchar2(25),
  to_segment3                 varchar2(25),
  to_segment4                 varchar2(25),
  to_segment5                 varchar2(25),
  to_segment6                 varchar2(25),
  to_segment7                 varchar2(25),
  to_segment8                 varchar2(25),
  to_segment9                 varchar2(25),
  to_segment10                varchar2(25),
  to_segment11                 varchar2(25),
  to_segment12                 varchar2(25),
  to_segment13                 varchar2(25),
  to_segment14                 varchar2(25),
  to_segment15                 varchar2(25),
  to_segment16                 varchar2(25),
  to_segment17                 varchar2(25),
  to_segment18                 varchar2(25),
  to_segment19                 varchar2(25),
  to_segment20                varchar2(25),
  to_segment21                 varchar2(25),
  to_segment22                 varchar2(25),
  to_segment23                 varchar2(25),
  to_segment24                 varchar2(25),
  to_segment25                 varchar2(25),
  to_segment26                 varchar2(25),
  to_segment27                 varchar2(25),
  to_segment28                 varchar2(25),
  to_segment29                 varchar2(25),
  to_segment30                varchar2(25),
  transfer_from_cc_id         number(15),
  transfer_to_cc_id           number(15)
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
--   Public.
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
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_finance_header_id                  in number,
  p_object_version_number              in number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Pre Conditions:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Arguments:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
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
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_finance_header_id                  in number,
  p_object_version_number              in number
  );
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_finance_header_id             in number,
	p_superceding_header_id         in number,
	p_authorizer_person_id          in number,
	p_organization_id               in number,
	p_administrator                 in number,
	p_cancelled_flag                in varchar2,
	p_currency_code                 in varchar2,
	p_date_raised                   in date,
	p_object_version_number         in number,
	p_payment_status_flag           in varchar2,
	p_transfer_status               in varchar2,
	p_type                          in varchar2,
	p_receivable_type               in varchar2,
	p_comments                      in varchar2,
	p_external_reference            in varchar2,
	p_invoice_address               in varchar2,
	p_invoice_contact               in varchar2,
	p_payment_method                in varchar2,
	p_pym_attribute1                in varchar2,
	p_pym_attribute10               in varchar2,
	p_pym_attribute11               in varchar2,
	p_pym_attribute12               in varchar2,
	p_pym_attribute13               in varchar2,
	p_pym_attribute14               in varchar2,
	p_pym_attribute15               in varchar2,
	p_pym_attribute16               in varchar2,
	p_pym_attribute17               in varchar2,
	p_pym_attribute18               in varchar2,
	p_pym_attribute19               in varchar2,
	p_pym_attribute2                in varchar2,
	p_pym_attribute20               in varchar2,
	p_pym_attribute3                in varchar2,
	p_pym_attribute4                in varchar2,
	p_pym_attribute5                in varchar2,
	p_pym_attribute6                in varchar2,
	p_pym_attribute7                in varchar2,
	p_pym_attribute8                in varchar2,
	p_pym_attribute9                in varchar2,
	p_pym_information_category      in varchar2,
	p_transfer_date                 in date,
	p_transfer_message              in varchar2,
	p_vendor_id                     in number,
	p_contact_id                    in number,
	p_address_id                    in number,
	p_customer_id                   in number,
	p_tfh_information_category      in varchar2,
	p_tfh_information1              in varchar2,
	p_tfh_information2              in varchar2,
	p_tfh_information3              in varchar2,
	p_tfh_information4              in varchar2,
	p_tfh_information5              in varchar2,
	p_tfh_information6              in varchar2,
	p_tfh_information7              in varchar2,
	p_tfh_information8              in varchar2,
	p_tfh_information9              in varchar2,
	p_tfh_information10             in varchar2,
	p_tfh_information11             in varchar2,
	p_tfh_information12             in varchar2,
	p_tfh_information13             in varchar2,
	p_tfh_information14             in varchar2,
	p_tfh_information15             in varchar2,
	p_tfh_information16             in varchar2,
	p_tfh_information17             in varchar2,
	p_tfh_information18             in varchar2,
	p_tfh_information19             in varchar2,
	p_tfh_information20             in varchar2,
      p_paying_cost_center            in varchar2,
      p_receiving_cost_center         in varchar2 ,
      p_transfer_from_set_of_book_id in number,
      p_transfer_to_set_of_book_id   in number,
      p_from_segment1                 in varchar2,
      p_from_segment2                 in varchar2,
      p_from_segment3                 in varchar2,
      p_from_segment4                 in varchar2,
      p_from_segment5                 in varchar2,
      p_from_segment6                 in varchar2,
      p_from_segment7                 in varchar2,
      p_from_segment8                 in varchar2,
      p_from_segment9                 in varchar2,
      p_from_segment10                in varchar2,
	p_from_segment11                 in varchar2,
      p_from_segment12                 in varchar2,
      p_from_segment13                 in varchar2,
      p_from_segment14                 in varchar2,
      p_from_segment15                 in varchar2,
      p_from_segment16                 in varchar2,
      p_from_segment17                 in varchar2,
      p_from_segment18                 in varchar2,
      p_from_segment19                 in varchar2,
      p_from_segment20                in varchar2,
	p_from_segment21                 in varchar2,
      p_from_segment22                 in varchar2,
      p_from_segment23                 in varchar2,
      p_from_segment24                 in varchar2,
      p_from_segment25                 in varchar2,
      p_from_segment26                 in varchar2,
      p_from_segment27                 in varchar2,
      p_from_segment28                 in varchar2,
      p_from_segment29                 in varchar2,
      p_from_segment30                in varchar2,
      p_to_segment1                 in varchar2,
      p_to_segment2                 in varchar2,
      p_to_segment3                 in varchar2,
      p_to_segment4                 in varchar2,
      p_to_segment5                 in varchar2,
      p_to_segment6                 in varchar2,
      p_to_segment7                 in varchar2,
      p_to_segment8                 in varchar2,
      p_to_segment9                 in varchar2,
      p_to_segment10                in varchar2,
	p_to_segment11                 in varchar2,
      p_to_segment12                 in varchar2,
      p_to_segment13                 in varchar2,
      p_to_segment14                 in varchar2,
      p_to_segment15                 in varchar2,
      p_to_segment16                 in varchar2,
      p_to_segment17                 in varchar2,
      p_to_segment18                 in varchar2,
      p_to_segment19                 in varchar2,
      p_to_segment20                in varchar2,
	p_to_segment21                 in varchar2,
      p_to_segment22                 in varchar2,
      p_to_segment23                 in varchar2,
      p_to_segment24                 in varchar2,
      p_to_segment25                 in varchar2,
      p_to_segment26                 in varchar2,
      p_to_segment27                 in varchar2,
      p_to_segment28                 in varchar2,
      p_to_segment29                 in varchar2,
      p_to_segment30                in varchar2,
      p_transfer_from_cc_id          in number,
      p_transfer_to_cc_id            in number
	)
	Return g_rec_type;
--
end ota_tfh_api_shd;

 

/
