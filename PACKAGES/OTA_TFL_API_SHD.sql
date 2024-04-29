--------------------------------------------------------
--  DDL for Package OTA_TFL_API_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFL_API_SHD" AUTHID CURRENT_USER as
/* $Header: ottfl01t.pkh 120.0 2005/05/29 07:41:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  finance_line_id                   number(9),
  finance_header_id                 number(9),
  cancelled_flag                    varchar2(30),
  date_raised                       date,
  line_type                         varchar2(30),
  object_version_number             number(9),
  sequence_number                   number(9),
  transfer_status                   varchar2(30),
  comments                          varchar2(2000),
  currency_code                     varchar2(30),
  money_amount                      number,
  standard_amount                   number,
  trans_information_category        varchar2(30),
  trans_information1                varchar2(150),
  trans_information10               varchar2(150),
  trans_information11               varchar2(150),
  trans_information12               varchar2(150),
  trans_information13               varchar2(150),
  trans_information14               varchar2(150),
  trans_information15               varchar2(150),
  trans_information16               varchar2(150),
  trans_information17               varchar2(150),
  trans_information18               varchar2(150),
  trans_information19               varchar2(150),
  trans_information2                varchar2(150),
  trans_information20               varchar2(150),
  trans_information3                varchar2(150),
  trans_information4                varchar2(150),
  trans_information5                varchar2(150),
  trans_information6                varchar2(150),
  trans_information7                varchar2(150),
  trans_information8                varchar2(150),
  trans_information9                varchar2(150),
  transfer_date                     date,
  transfer_message                  varchar2(240),
  unitary_amount                    number(17,2),     -- Increased length
  booking_deal_id                   number(9),
  booking_id                        number(9),
  resource_allocation_id            number(9),
  resource_booking_id               number(9),
  tfl_information_category          varchar2(30),
  tfl_information1                  varchar2(150),
  tfl_information2                  varchar2(150),
  tfl_information3                  varchar2(150),
  tfl_information4                  varchar2(150),
  tfl_information5                  varchar2(150),
  tfl_information6                  varchar2(150),
  tfl_information7                  varchar2(150),
  tfl_information8                  varchar2(150),
  tfl_information9                  varchar2(150),
  tfl_information10                 varchar2(150),
  tfl_information11                 varchar2(150),
  tfl_information12                 varchar2(150),
  tfl_information13                 varchar2(150),
  tfl_information14                 varchar2(150),
  tfl_information15                 varchar2(150),
  tfl_information16                 varchar2(150),
  tfl_information17                 varchar2(150),
  tfl_information18                 varchar2(150),
  tfl_information19                 varchar2(150),
  tfl_information20                 varchar2(150)
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
  p_finance_line_id                    in number,
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
  p_finance_line_id                    in number,
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
	p_finance_line_id               in number,
	p_finance_header_id             in number,
	p_cancelled_flag                in varchar2,
	p_date_raised                   in date,
	p_line_type                     in varchar2,
	p_object_version_number         in number,
	p_sequence_number               in number,
	p_transfer_status               in varchar2,
	p_comments                      in varchar2,
	p_currency_code                 in varchar2,
	p_money_amount                  in number,
	p_standard_amount               in number,
	p_trans_information_category    in varchar2,
	p_trans_information1            in varchar2,
	p_trans_information10           in varchar2,
	p_trans_information11           in varchar2,
	p_trans_information12           in varchar2,
	p_trans_information13           in varchar2,
	p_trans_information14           in varchar2,
	p_trans_information15           in varchar2,
	p_trans_information16           in varchar2,
	p_trans_information17           in varchar2,
	p_trans_information18           in varchar2,
	p_trans_information19           in varchar2,
	p_trans_information2            in varchar2,
	p_trans_information20           in varchar2,
	p_trans_information3            in varchar2,
	p_trans_information4            in varchar2,
	p_trans_information5            in varchar2,
	p_trans_information6            in varchar2,
	p_trans_information7            in varchar2,
	p_trans_information8            in varchar2,
	p_trans_information9            in varchar2,
	p_transfer_date                 in date,
	p_transfer_message              in varchar2,
	p_unitary_amount                in number,
	p_booking_deal_id               in number,
	p_booking_id                    in number,
	p_resource_allocation_id        in number,
	p_resource_booking_id           in number,
	p_tfl_information_category      in varchar2,
	p_tfl_information1              in varchar2,
	p_tfl_information2              in varchar2,
	p_tfl_information3              in varchar2,
	p_tfl_information4              in varchar2,
	p_tfl_information5              in varchar2,
	p_tfl_information6              in varchar2,
	p_tfl_information7              in varchar2,
	p_tfl_information8              in varchar2,
	p_tfl_information9              in varchar2,
	p_tfl_information10             in varchar2,
	p_tfl_information11             in varchar2,
	p_tfl_information12             in varchar2,
	p_tfl_information13             in varchar2,
	p_tfl_information14             in varchar2,
	p_tfl_information15             in varchar2,
	p_tfl_information16             in varchar2,
	p_tfl_information17             in varchar2,
	p_tfl_information18             in varchar2,
	p_tfl_information19             in varchar2,
	p_tfl_information20             in varchar2
	)
	Return g_rec_type;
--
end ota_tfl_api_shd;

 

/
